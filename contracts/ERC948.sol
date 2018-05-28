pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract ERC948 {

	struct Subscription {
        address owner;
        address payeeAddress;
        address tokenAddress;
        uint amountRecurring;
        uint amountInitial;
        uint periodMultiplier;
        uint startTime;
        string data;
        bool active;

        // uint _periodType;
        // uint terminationDate;
        // uint nextPaymentTime;
    }

    mapping (bytes32 => Subscription) public subscriptions;

    event NewSubscription(
        bytes32 _subscriptionId,
        address _payeeAddress,
        address _tokenAddress,
        uint _amountRecurring,
        uint _amountInitial,
        uint _periodType,
        uint _periodMultiplier,
        uint _startTime
        );

    /**
    * @dev Called by the subscriber on their own wallet, using data initiated by the merchant in a checkout flow.
    * @param _payeeAddress The address that will receive payments
    * @param _tokenAddress The address of the token contract that is used for payments
    * @param _amountRecurring The maximum amount that can be paid in each subscription period
    * @param _amountInitial The amount to be paid immediately, can be lower than total allowable amount
    * @param _periodType Can be hour, day, week, month, year
    * @param _periodMultiplier The number of periodType that must elapse before the next payment is due
    * @param _startTime Date that the subscription becomes active
    * @return A bytes32 for the created subscriptionId
    */
    function createSubscription(
        address _payeeAddress,
        address _tokenAddress,
        uint _amountRecurring,
        uint _amountInitial,
        uint _periodType,
        uint _periodMultiplier,
        uint _startTime,
        string _data
        )
        public
        returns (bytes32)
    {
        // Check that subscription start time is now or in the future
        require((_startTime >= block.timestamp),
                'Subscription must not start in the past');

        // Check that owner has a balance of at least the initial and first recurring payment
        StandardToken token = StandardToken(_tokenAddress);
        uint amountRequired = _amountInitial + _amountRecurring;
        require((token.balanceOf(msg.sender) >= amountRequired),
                'Insufficient balance for initial + 1x recurring amount');

        //  Check that contact has approval for at least the initial and first recurring payment
        require((token.allowance(msg.sender, this) >= amountRequired),
                'Insufficient approval for initial + 1x recurring amount');

        Subscription memory newSubscription = Subscription({
            owner: msg.sender,
            payeeAddress: _payeeAddress,
            tokenAddress: _tokenAddress,
            amountRecurring: _amountRecurring,
            amountInitial: _amountInitial,
            periodMultiplier: _periodMultiplier,
            startTime: _startTime,
            data: _data,
            active: true

            // TODO set period  &  nextPaymentTime
        });

        // Save subscription
        bytes32 subscriptionId = keccak256(msg.sender, block.timestamp);
        subscriptions[subscriptionId] = newSubscription;
        // TODO check for existing subscriptionId

        // Make initial payment
        token.transferFrom(msg.sender, _payeeAddress, _amountInitial);

        // Emit NewSubscription event
        emit NewSubscription(
            subscriptionId,
            _payeeAddress,
            _tokenAddress,
            _amountRecurring,
            _amountInitial,
            _periodType,
            _periodMultiplier,
            _startTime
            );

        return subscriptionId;
    }

    /**
    * @dev Called by or on behalf of the merchant, in order to initiate a scheduled/approved payment.
    * @param _subscriptionId The subscription ID to process payments for
    * @param _amount Amount to be transferred, can be lower than total allowable amount
    * @return A boolean to indicate whether the payment was successful
    */
    function processSubscription(
        bytes32 _subscriptionId,
        uint _amount
        )
        public
        returns (bool)
    {
        Subscription storage subscription = subscriptions[_subscriptionId];

        require(_amount < subscription.amountRecurring);
        require(block.timestamp > subscription.startTime);

        // TODO ensure that a payment is due

        StandardToken token = StandardToken(subscription.tokenAddress);
        token.transferFrom(subscription.owner, subscription.payeeAddress, _amount);
        return true;
    }
}
