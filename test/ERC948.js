// import assertRevert from "zeppelin-solidity/test/helpers/assertRevert";

const TestToken = artifacts.require("TestToken");
const ERC948 = artifacts.require("ERC948");


contract("TestToken", accounts => {
  it("Should make first account an owner", async () => {
    let instance = await TestToken.deployed();
    let owner = await instance.owner();
    assert.equal(owner, accounts[0]);
  });

  it("Should give the owner 1000 tokens", async () => {
    let instance = await TestToken.deployed();
    let balance = (await instance.balanceOf.call(accounts[0])).toNumber();

    assert.equal(balance, 1000);
  });
});


contract("ERC948", accounts => {

  async function createValidSubscription(TokenInstance, ERC948Instance) {
    // Approve the ERC948 contract to make transfers for accounts[0]
    await TokenInstance.approve(ERC948Instance.address, 1000);

    // We must use a start time that is now or in the future
    let current_timestamp = Math.round((new Date()).getTime() / 1000);

    let response = await ERC948Instance.createSubscription(
      accounts[1],            //address _payeeAddress,
      TokenInstance.address,  //address _tokenAddress,
      1,                      //uint _amountRecurring,
      2,                      //uint _amountInitial,
      0,                      //uint _periodType,
      30,                     //uint _periodMultiplier,
      current_timestamp+10,   //uint _startTime,
      "",                     //string _data
      {from: accounts[0],
        gas: "4712388"});

    return response;
  }

  // Return the first matching event in a tx response
  function findEvent(response, eventName) {
    for (var i = 0; i < response.logs.length; i++) {
      var log = response.logs[i];

      if (log.event == eventName) {
        // We found the event!
        return log;
      }
    }
    return false;
  }

  it("Should allow you to create a subscription with valid params", async () => {
    let TokenInstance = await TestToken.deployed();
    let ERC948Instance = await ERC948.deployed();

    let response = await createValidSubscription(TokenInstance, ERC948Instance);
    assert.property(response, 'tx');
  });

  it("Should emit a NewSubscription event", async () => {
    let TokenInstance = await TestToken.deployed();
    let ERC948Instance = await ERC948.deployed();

    let response = await createValidSubscription(TokenInstance, ERC948Instance);

    let success = false;

    if (event = findEvent(response, "NewSubscription")) {
        // We found the event!
        success = true;
    }

    assert.equal(success, true);
  });

  it("Should emit a NewSubscription event with a bytes32 subscription ID", async () => {
    let TokenInstance = await TestToken.deployed();
    let ERC948Instance = await ERC948.deployed();

    let response = await createValidSubscription(TokenInstance, ERC948Instance);
    let subId = undefined;

    if (event = findEvent(response, "NewSubscription")) {
        // We found the event!
        subId = event.args._subscriptionId;
    }
    assert.lengthOf(subId, 66)
  });


});
