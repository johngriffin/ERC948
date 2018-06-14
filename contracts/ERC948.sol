pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'BokkyPooBahsDateTimeLibrary.sol';

contract ERC948 {

		enum PeriodType {
        Second
    }

		struct Subscription {
        address owner;
        address payeeAddress;
        address tokenAddress;
        uint amountRecurring;
        uint amountInitial;
        uint periodType;
        uint periodMultiplier;
        uint startTime;
        string data;
        bool active;
        uint nextPaymentTime;

        // uint terminationDate;
    }

    mapping (bytes32 => Subscription) public subscriptions;
    mapping (address => bytes32[]) public subscribers_subscriptions;

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
        // Ensure that _periodType is valid
        // TODO support hour, day, week, month, year

        //Already have library imported, but this is a helpful referecnce
        /* function addYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addYears(timestamp, _years);
    }
    function addMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addMonths(timestamp, _months);
    }
    function addDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addDays(timestamp, _days);
    }
    function addHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {
        newTimestamp = BokkyPooBahsDateTimeLibrary.addHours(timestamp, _hours);
    } */

        require((_periodType == 0),
                'Only period types of second are supported');

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
            periodType: _periodType,
            periodMultiplier: _periodMultiplier,

            // TODO set start time appropriately and deal with interaction w nextPaymentTime
            startTime: block.timestamp,

            data: _data,
            active: true,

            // TODO support hour, day, week, month, year
            nextPaymentTime: block.timestamp + _periodMultiplier
        });

        // Save subscription
        bytes32 subscriptionId = keccak256(msg.sender, block.timestamp);
        subscriptions[subscriptionId] = newSubscription;
        // TODO check for existing subscriptionId

        // Add subscription to subscriber
        subscribers_subscriptions[msg.sender].push(subscriptionId);

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
    * @dev Get all subscriptions for a subscriber address
    * @param _subscriber The address of the subscriber
    * @return An array of bytes32 values that map to subscriptions
    */
     function getSubscribersSubscriptions(address _subscriber)
        public
        view
        returns (bytes32[])
    {
        return subscribers_subscriptions[_subscriber];
    }

    /**
    * @dev Delete a subscription
    * @param  _subscriptionId The subscription ID to delete
    * @return true if the subscription has been deleted
    */
    function cancelSubscription(bytes32 _subscriptionId)
        public
        returns (bool)
    {
        Subscription storage subscription = subscriptions[_subscriptionId];
        require((subscription.payeeAddress == msg.sender)
            || (subscription.owner == msg.sender));

        delete subscriptions[_subscriptionId];
        return true;
    }

    /**
    * @dev Called by or on behalf of the merchant to find whether a subscription has a payment due
    * @param _subscriptionId The subscription ID to process payments for
    * @return A boolean to indicate whether a payment is due
    */
    function paymentDue(bytes32 _subscriptionId)
        public
        view
        returns (bool)
    {
        Subscription memory subscription = subscriptions[_subscriptionId];

        // Check this is an active subscription
        require((subscription.active == true), 'Not an active subscription');

        // Check that subscription start time has passed
        require((subscription.startTime <= block.timestamp),
            'Subscription has not started yet');

        // Check whether required time interval has passed since last payment
        if (subscription.nextPaymentTime <= block.timestamp) {
            return true;
        }
        else {
            return false;
        }
    }

    /**
    * @dev Called by or on behalf of the merchant, in order to initiate a payment.
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

        require((_amount <= subscription.amountRecurring),
            'Requested amount is higher than authorized');

        require((paymentDue(_subscriptionId)),
            'A Payment is not due for this subscription');

        StandardToken token = StandardToken(subscription.tokenAddress);
        token.transferFrom(subscription.owner, subscription.payeeAddress, _amount);

        // Increment subscription nextPaymentTime by one interval
        // TODO support hour, day, week, month, year
        subscription.nextPaymentTime = subscription.nextPaymentTime + subscription.periodMultiplier;
        return true;

        //TODO - takes periodType and increments the subscription until further notice 
        function incrementNextPaymentTime(periodType){
             subscription.nextPaymentTime = uint32(subscription.nextPaymentTime + periodType);
            }
    }

}
