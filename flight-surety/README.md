# Development Notes - udacity-blockchain-projects

Project work for Udacity blockchain course

### Setup

```
Reference Commands:

  Compile:              truffle compile
  Migrate:              truffle migrate
  Test contracts:       truffle test
  Run dev server:       cd app && npm run dev
  Build for production: cd app && npm run build

```

# Openzeppelin and hdwallet versions

```bash
npm install --save  openzeppelin-solidity@2.3
npm install --save  truffle-hdwallet-provider@1.0.17
```

```bash

$ truffle version

Truffle v5.4.9 (core: 5.4.9)
Solidity v0.5.16 (solc-js)
Node v14.15.1
Web3.js v1.5.2

```

```bash
# Install bignumber js

$ npm install bignumber.js@8.0.2

```

### Truffle migrate/deploy with additional parameters

- [Truffle Migrations Explained](https://www.sitepoint.com/truffle-migrations-explained/)

### Truffle develop

```bash

$ truffle develop

truffle(develop) > compile
truffle(develop) > migrate --reset
truffle(develop) > test ./test/flightSurety.js

```

### test results

```bash

truffle(develop)> test ./test/flightSurety.js

Compiling your contracts...
===========================
> Compiling ./contracts/FlightSuretyApp.sol
> Compiling ./contracts/FlightSuretyData.sol
> Compiling ./contracts/Migrations.sol
> Compiling ./node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol
> Artifacts written to /tmp/test--70634-c6aqxAMhdK1m
> Compiled successfully using:
   - solc: 0.5.16+commit.9c3226ce.Emscripten.clang



  Contract: Flight Surety Tests
    ✓ (multiparty) has correct initial isOperational() value (81ms)
    ✓ (multiparty) can block access to setOperatingStatus() for non-Contract Owner account (2815ms)
    ✓ (multiparty) can allow access to setOperatingStatus() for Contract Owner account (275ms)
    ✓ (multiparty) can block access to functions using requireIsOperational when operating status is false (529ms)
    ✓ Only existing airline may register a new airline until there are at least four airlines registered (525ms)
    ✓ Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines (1979ms)
    ✓ (airline) CAN register an Airline using registerAirline() if it is funded (246ms)
    ✓ (airline) cannot register an Airline using registerAirline() if it is not funded
    ✓ Passengers can choose from a fixed list of flight numbers and departure (1106ms)
    ✓ Passengers may purchase flight insurance upto 1 (692ms)
    ✓ If flight delayed passenger receives 1.5X amount they paid (736ms)


  11 passing (11s)

```
