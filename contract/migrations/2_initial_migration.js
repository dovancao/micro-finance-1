var MicroFinance = artifacts.require("./MicroFinance.sol");

module.exports = function(deployer) {
  deployer.deploy(MicroFinance);
};
