pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract ERC948 {

	struct Subscription {
        address owner;
        address payeeAddress;
        address tokenAddress;
        uint amountRecurring;
        uint amountInitial;
        uint periodMultiplier;
        uint startTime;
        uint externalSubId;
        string data;
        bool active;

        // TODO - create a struct for period
        // uint _periodType;
        // uint terminationDate;
        // uint nextPaymentTime;

    }

    mapping (bytes32 => Subscription) public subscriptions;

    /**
    * @dev Called by the subscriber on their own wallet, using data initiated by the merchant in a checkout flow.
    * @param _payeeAddress The address that will receive payments
    * @param _tokenAddress The address of the token contract that is used for payments
    * @param _amountRecurring The maximum amount that can be paid in each subscription period
    * @param _amountInitial The amount to be paid immediately, can be lower than total allowable amount
    * @param _periodType Can be hour, day, week, month, year
    * @param _periodMultiplier The number of periodType that must elapse before the next payment is due
    * @param _startTime Date that the subscription becomes active
    * @param _externalSubId A unique ID for this subscription
    * @return A boolean to indicate whether the subscription was created successfully
    */
    function createSubscription(
        address _payeeAddress,
        address _tokenAddress,
        uint _amountRecurring,
        uint _amountInitial,
        uint _periodType,
        uint _periodMultiplier,
        uint _startTime,
        uint _externalSubId,
        string _data
        )
        public
        returns (bool success)
    {
        require(msg.sender != 0x0);
        require(_startTime >= block.timestamp);
        require(_externalSubId != 0);

        // TODO avoid hash clash
        // require(subscriptions[keccak256(_externalSubId)] == false);

        Subscription memory newSubscription = Subscription({

            owner: msg.sender,
            payeeAddress: _payeeAddress,
            tokenAddress: _tokenAddress,
            amountRecurring: _amountRecurring,
            amountInitial: _amountInitial,
            periodMultiplier: _periodMultiplier,
            startTime: _startTime,
            externalSubId: _externalSubId,
            data: _data,
            active: true

            // TODO set period  &  nextPaymentTime
        });

        // Save subscription
        subscriptions[keccak256(_externalSubId)] = newSubscription;

        // take initial payment
        // authorize future payments
        // emit event
        // return
    }

    /**
    * @dev Called by or on behalf of the merchant, in order to initiate a scheduled/approved payment.
    * @param _externalSubId The subscription ID to process payments for
    * @param _amount Amount to be transferred, can be lower than total allowable amount
    * @return A boolean to indicate whether the payment was successful
    */
    function processSubscription(
        uint _externalSubId,
        uint _amount
        )
        public
        returns (bool success)
    {
        Subscription storage subscription = subscriptions[keccak256(_externalSubId)];

        require(_amount < subscription.amountRecurring);

        // TODO ensure that a payment is due

        StandardToken token;
        token.transferFrom(subscription.owner, subscription.payeeAddress, _amount);
        return true;
    }


}
