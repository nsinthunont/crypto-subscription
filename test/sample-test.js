const { expectRevert, constants, time } = require('@openzeppelin/test-helpers');
const { assert } = require('chai')

const THIRTY_DAYS = time.duration.days(30).toNumber();
const SIXTY_DAYS = time.duration.days(60).toNumber();

//require('chai').use(require('chai-as-promised')).should()

describe("Payment", function () {

  let subscription, nstoken, merchant, subscriber1, subscriber2, subscriber3;

  beforeEach(async () => {

    const Subscription = await ethers.getContractFactory("Subscription");
    subscription = await Subscription.deploy();
    await subscription.deployed()

    const NSToken = await ethers.getContractFactory("NSToken");
    nstoken = await NSToken.deploy();
    await nstoken.deployed();

    [_, merchant, subscriber1, subscriber2, subscriber3] = await ethers.getSigners();

    await nstoken.transfer(subscriber1.address, 1000);
    await nstoken.transfer(subscriber2.address, 500);
    await nstoken.transfer(subscriber3.address, 100);

    await nstoken.connect(subscriber1).approve(subscription.address, 1000);
    await nstoken.connect(subscriber2).approve(subscription.address, 500);
    await nstoken.connect(subscriber3).approve(subscription.address, 100);

  });

  it("should create a plan and sign up 3 subscribers", async function () {

    await subscription.connect(merchant).createPlan(merchant.address, nstoken.address, 1, THIRTY_DAYS);
    let plan = (await subscription.getPlans())[0];

    await subscription.connect(subscriber1).createAgreement(plan.id.toNumber(), subscriber1.address)
    await subscription.connect(subscriber2).createAgreement(plan.id.toNumber(), subscriber2.address)
    await subscription.connect(subscriber3).createAgreement(plan.id.toNumber(), subscriber3.address)

  });

  it("should create a plan and sign up 2 subscribers. 1 subscriber will fail to signup due to insufficient balance", async function () {

    await subscription.connect(merchant).createPlan(merchant.address, nstoken.address, 200, THIRTY_DAYS);
    let plan = (await subscription.getPlans())[0];

    await subscription.connect(subscriber1).createAgreement(plan.id.toNumber(), subscriber1.address)
    await subscription.connect(subscriber2).createAgreement(plan.id.toNumber(), subscriber2.address)

    await expectRevert.unspecified(
      subscription.connect(subscriber3).createAgreement(plan.id.toNumber(), subscriber3.address)
    );

  });

  it("should create a plan, sign up 1 subscriber and pay", async function () {

    await subscription.connect(merchant).createPlan(merchant.address, nstoken.address, 200, THIRTY_DAYS);
    let plan = (await subscription.getPlans())[0];

    await subscription.connect(subscriber1).createAgreement(plan.id.toNumber(), subscriber1.address);
    await subscription.connect(subscriber1).makePayment(plan.id.toNumber(), subscriber1.address);
    await subscription.connect(subscriber1).makePayment(plan.id.toNumber(), subscriber1.address);
    await subscription.connect(subscriber1).makePayment(plan.id.toNumber(), subscriber1.address);

    assert((await nstoken.balanceOf(subscriber1.address)).toNumber() == 200, "incorrect balance");

  });

  it("should create a plan, sign up 1 subscriber and cancel plan", async function(){

    await subscription.connect(merchant).createPlan(merchant.address, nstoken.address, 200, THIRTY_DAYS);
    let plan = (await subscription.getPlans())[0];

    await subscription.connect(subscriber1).createAgreement(plan.id.toNumber(), subscriber1.address);
    await subscription.cancelAgreement(1,subscriber1.address);

    const agreement = await subscription.idToSubscriberToAgreement(1,subscriber1.address);
    assert(agreement.subscriber === constants.ZERO_ADDRESS);

  });
  

});
