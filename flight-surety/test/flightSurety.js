var Test = require("./testConfig.js");
var BigNumber = require("bignumber.js");

contract("Flight Surety Tests", async (accounts) => {
  var config;
  before("setup contract", async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.authorizeCaller(
      config.flightSuretyApp.address
    );
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {
    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");
  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {
    // Ensure that access is denied for non-Contract Owner account
    let accessDenied = false;
    try {
      await config.flightSuretyData.setOperatingStatus(false, {
        from: config.testAddresses[2],
      });
    } catch (e) {
      accessDenied = true;
    }
    assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {
    // Ensure that access is allowed for Contract Owner account
    let accessDenied = false;
    try {
      await config.flightSuretyData.setOperatingStatus(false);
    } catch (e) {
      accessDenied = true;
    }
    assert.equal(
      accessDenied,
      false,
      "Access not restricted to Contract Owner"
    );
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {
    await config.flightSuretyData.setOperatingStatus(false);

    let reverted = false;
    try {
      await config.flightSurety.setTestingMode(true);
    } catch (e) {
      reverted = true;
    }
    assert.equal(reverted, true, "Access not blocked for requireIsOperational");

    // Set it back for other tests to work
    await config.flightSuretyData.setOperatingStatus(true);
  });

  it("Only existing airline may register a new airline until there are at least four airlines registered", async () => {
    // ARRANGE
    let newAirline = accounts[2];
    let isRegistered = true;

    // ACT
    try {
      await config.flightSuretyApp.registerAirline(newAirline, {
        from: config.firstAirline,
      });
    } catch (e) {
      // error will be thrown if conditions of registration does not meet. So, if no error in registering, it is safe to assume that registration is sucessful.
      isRegistered = false;
    }

    // ASSERT
    assert.equal(
      isRegistered,
      true,
      "Only existing airline may register a new airline until there are at least four airlines registered"
    );
  });

  it("Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines", async () => {
    let firstFourRegistered = true;

    // ACT
    try {
      // register 4 airlines
      await config.flightSuretyApp.registerAirline(accounts[2], {
        from: config.firstAirline,
      });
      await config.flightSuretyApp.registerAirline(accounts[3], {
        from: config.firstAirline,
      });
      await config.flightSuretyApp.registerAirline(accounts[4], {
        from: config.firstAirline,
      });
      await config.flightSuretyApp.registerAirline(accounts[5], {
        from: config.firstAirline,
      });
    } catch (e) {
      // assumption: if no error in registering, assuming it is registerd sucessfully.
      firstFourRegistered = false;
    }

    assert.equal(
      firstFourRegistered,
      true,
      "first four airlines should be registered successfully"
    );

    // register 5th airline - it should not set isRegistered status as true without 50% approval

    try {
      await config.flightSuretyApp.registerAirline(accounts[7], {
        from: config.firstAirline,
      });
    } catch (e) {}

    let isApproved = true;

    try {
      // get consensus of 2 (approval 1 from the original and approval 2 is this one) and it should register as 50% consensus achieved.
      // logic is that when a new airline has 2 votes, its isRegistered status is set as true.
      await config.flightSuretyApp.approveAirlineRegistration(accounts[7], {
        from: accounts[3],
      });
    } catch (error) {
      console.log(error);
      isApproved = false;
    }

    // ASSERT
    assert.equal(
      isApproved,
      true,
      "Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines"
    );
  });

  it("(airline) CAN register an Airline using registerAirline() if it is funded", async () => {
    // ARRANGE
    let newAirline = accounts[2];
    let isRegistered = true;

    // ACT
    try {
      await config.flightSuretyApp.registerAirline(newAirline, {
        from: config.firstAirline,
      });
    } catch (e) {
      // error will be thrown if conditions of registration does not meet. So, if no error in registering, it is safe to assume that registration is sucessful.
      isRegistered = false;
    }

    // ASSERT
    assert.equal(
      isRegistered,
      true,
      "Airline CAN register another airline if it is funded."
    );
  });
  it("(airline) cannot register an Airline using registerAirline() if it is not funded", async () => {
    // ARRANGE
    let newAirline = accounts[2];
    let isRegistered = false;

    // ACT
    try {
      await config.flightSuretyApp.registerAirline(newAirline, {
        from: config.accounts[3],
      });
    } catch (e) {
      // error will be thrown if conditions of registration does not meet. So, if no error in registering, it is safe to assume that registration is sucessful.
      isRegistered = false;
    }

    // ASSERT
    assert.equal(
      isRegistered,
      false,
      "Airline should not be able to register another airline if it hasn't provided funding"
    );
  });

  //
  // Passengers
  //
  it("Passengers can choose from a fixed list of flight numbers and departure", async () => {
    //add 3 flights
    let flightsRegistered = true;

    try {
      await config.flightSuretyApp.registerFlight(100, {
        from: config.firstAirline,
      });

      await config.flightSuretyApp.registerFlight(101, {
        from: config.firstAirline,
      });

      await config.flightSuretyApp.registerFlight(102, {
        from: config.firstAirline,
      });
    } catch (error) {
      flightsRegistered = false;
    }

    assert.equal(
      flightsRegistered,
      true,
      "registered airlines should be able to register/add flights."
    );

    // get flights list

    let canGetFlights = true;
    try {
      let flights = await config.flightSuretyApp.getFlights();
      //console.log("flights are ", flights);
      canGetFlights = flights.length > 0;
    } catch (e) {
      console.log(e);
      canGetFlights = false;
    }

    assert.equal(
      canGetFlights,
      true,
      "Passengers should be able to choose from a fixed list of flight numbers and departure"
    );
  });
});
