// contracts/SubscriPaymentption.sol
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Subscription is ReentrancyGuard{

    using Counters for Counters.Counter;

    Counters.Counter private _planIds;

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    struct Plan {
        uint id;
        address merchant;
        address token;
        uint amount;
        uint frequency;
    }

    struct Agreement {
        address subscriber;
        uint createdAt;
        uint nextPayment;
    }

    mapping(uint => Plan) public idToPlan;
    mapping(uint => mapping(address => Agreement)) public idToSubscriberToAgreement; // e.g. agreement[planId][address]

    event PlanCreated(
        uint id,
        address merchant,
        address token,
        uint amount,
        uint frequency
    );

    event AgreementCreated(
        address subscriber,
        uint createdAt,
        uint nextPayment
    );

    event AgreementCancelled(
        uint planId,
        address subscriber,
        uint cancelledAt
    );

    event PaymentSent(
        uint planId,
        address subscriber,
        address merchant,
        uint amount,
        uint paidAt
    );

    function createPlan(
        address merchant, 
        address token,
        uint amount,
        uint frequency
        ) public payable nonReentrant{
            
            // checks
            require(merchant != address(0x0), 'invalid merchant');
            require(token != address(0x0), 'invalid token');
            require(amount > 0, 'amount must be greater than 0');
            require(frequency > 0, 'frequency must be greater than 0');

            // increment plan id
            _planIds.increment();
            uint planId = _planIds.current();

            // store plan in mapping
            idToPlan[planId] = Plan(
                planId,
                merchant,
                token,
                amount,
                frequency
            );

            emit PlanCreated(planId, merchant, token, amount, frequency);

    }

    function createAgreement(
        uint planId,
        address subscriber
    ) public payable nonReentrant{

        // checks
        require(planId > 0, "Plan ID needs to be greater than 0");
        require(planId <= _planIds.current(), "Plan ID is greater than plan count");
        require(subscriber != address(0x0), "Invalid subscriber");

        // get the plan
        Plan storage plan = idToPlan[planId];

        // create  new agreement
        idToSubscriberToAgreement[planId][subscriber] = Agreement(
            subscriber,
            block.timestamp,
            block.timestamp + plan.frequency
        );
        emit AgreementCreated(subscriber, block.timestamp, block.timestamp + plan.frequency);

        // make first payment
        IERC20 token = IERC20(plan.token);
        token.transferFrom(msg.sender, plan.merchant, plan.amount);
        emit PaymentSent(planId, subscriber, plan.merchant, plan.amount, block.timestamp);
        
    }

    function cancelAgreement(
        uint planId,
        address subscriber
    ) public {

        // checks
        require(planId > 0, "Plan ID needs to be greater than 0");
        require(planId <= _planIds.current(), "Plan ID is greater than plan count");
        require(subscriber != address(0x0), "Invalid subscriber");

        Agreement storage agreement = idToSubscriberToAgreement[planId][subscriber];
        require(agreement.subscriber != address(0), "agreement does not exist");

        delete idToSubscriberToAgreement[planId][subscriber];

        emit AgreementCancelled(planId, subscriber, block.timestamp);

    }

    function makePayment(
        uint planId,
        address subscriber
    ) public payable nonReentrant{

        // checks
        require(planId > 0, "Plan ID needs to be greater than 0");
        require(planId <= _planIds.current(), "Plan ID is greater than plan count");
        require(subscriber != address(0x0), "Invalid subscriber");

        Plan storage plan = idToPlan[planId];

        Agreement storage agreement = idToSubscriberToAgreement[planId][subscriber];
        require(agreement.subscriber != address(0), "agreement does not exist");

        // make payment
        IERC20 token = IERC20(plan.token);
        token.transferFrom(msg.sender, plan.merchant, plan.amount);
        emit PaymentSent(planId, subscriber, plan.merchant, plan.amount, block.timestamp);

    }

    function getPlans() public view returns (Plan[] memory){

        uint planCount = _planIds.current();

        Plan[] memory plans = new Plan[](planCount);

        for (uint i = 0; i < planCount; i++){
            Plan storage plan = idToPlan[i+1];
            plans[i] = plan;
        }

        return plans;

    }


}