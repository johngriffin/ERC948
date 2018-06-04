var TestToken = artifacts.require("TestToken");

module.exports = function(deployer) {
    deployer.deploy(TestToken);
};
