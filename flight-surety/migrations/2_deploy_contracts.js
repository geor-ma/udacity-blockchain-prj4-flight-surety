const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require("fs");

// https://www.sitepoint.com/truffle-migrations-explained/
module.exports = function (deployer, network, accounts) {
  let firstAirline = accounts[1];

  deployer.deploy(FlightSuretyData, firstAirline).then(() => {
    return deployer
      .deploy(FlightSuretyApp, FlightSuretyData.address)
      .then(() => {
        let config = {
          localhost: {
            url: "http://localhost:9545",
            dataAddress: FlightSuretyData.address,
            appAddress: FlightSuretyApp.address,
          },
        };
        fs.writeFileSync(
          __dirname + "/../dapp-config.json",
          JSON.stringify(config, null, "\t"),
          "utf-8"
        );
        fs.writeFileSync(
          __dirname + "/../server-config.json",
          JSON.stringify(config, null, "\t"),
          "utf-8"
        );
      });
  });
};
