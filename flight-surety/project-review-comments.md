Meets Specifications
Awesome
Great job! I've liked the way you've structured your code and functions, a nice test implementation as well!

Keep it up! :clap:

Improvements
You can improve your fantastic skills by reading this article
https://medium.com/@mycoralhealth/advanced-blockchain-concepts-for-beginners-32887202afad

I wish you good luck with your Nanodegree! Stay :udacious:!

Separation of Concerns, Operational Control and “Fail Fast”
Smart Contract code is separated into multiple contracts:

1. FlightSuretyData.sol for data persistence
2. FlightSuretyApp.sol for app logic and oracles code

Awesome
The smart contract code is properly separated into multiple contracts, well done :muscle:
:ok: FlightSuretyData.sol for data persistence
:ok: FlightSuretyApp.sol for app logic and oracles code

A Dapp client has been created and is used for triggering contract calls. Client can be launched with “npm run dapp” and is available at http://localhost:8000

Specific contract calls:

1. Passenger can purchase insurance for flight
2. Trigger contract to request flight status update

Awesome
The Dapp client properly works and allows to:
:ok: Passenger can purchase insurance for flight
:ok: Trigger contract to request flight status update

A server app has been created for simulating oracle behavior. Server can be launched with “npm run server”

Awesome
The server perfectly works, good job setting those oracles :muscle:

Students has implemented operational status control.

Awesome
The operational status control is perfectly implemented, this is awesome :muscle:

Contract functions “fail fast” by having a majority of “require()” calls at the beginning of function body

Awesome
Fantastic job with the required statements and calls

Resources
[Dapplets: Rethinking Dapp Architecture for better adoption and security](https://ethereum-magicians.org/t/dapplets-rethinking-dapp-architecture-for-better-adoption-and-security/2799)

Airlines
First airline is registered when contract is deployed.

Awesome
The first airline is properly registered when the contract is deployed, well done :muscle:

Only existing airline may register a new airline until there are at least four airlines registered

Demonstrated either with Truffle test or by making call from client Dapp

Awesome
Fantastic job handling the airline roles and capabilities, well done :muscle:

Registration of fifth and subsequent airlines requires multi-party consensus of 50% of registered airlines

Demonstrated either with Truffle test or by making call from client Dapp

Awesome
Good job implementing a multi-party consensus!

Resources
[Exploring Simpler Ethereum Multisig Contracts](https://medium.com/@ChrisLundkvist/exploring-simpler-ethereum-multisig-contracts-b71020c19037)

Airline can be registered, but does not participate in contract until it submits funding of 10 ether

Demonstrated either with Truffle test or by making call from client Dapp

Awesome
This is fantastic, well done :muscle:

Passengers
Passengers can choose from a fixed list of flight numbers and departure that are defined in the Dapp client

Awesome
A fixed list of flight numbers and departure is correctly implemented, well done :muscle:

Passengers may pay up to 1 ether for purchasing flight insurance.

Awesome
Passengers can properly purchase flight insurance, well done :muscle:

If flight is delayed due to airline fault, passenger receives credit of 1.5X the amount they paid

Awesome
Passengers get correctly refunded after a flight delay, well done :muscle:

Passenger can withdraw any funds owed to them as a result of receiving credit for insurance payout

Awesome
Passengers can properly withdraw funds, well done :muscle:

Insurance payouts are not sent directly to passenger’s wallet

Awesome
The insurance payouts are stored correctly in a balance, well done :muscle:

Oracles (Server App)
Oracle functionality is implemented in the server app.

Awesome
Fantastic job with the oracles, they are correctly implemented, well done :muscle:

Resources
[Building your first Ethereum Oracle – decentcrypto – Medium](https://medium.com/decentlabs/building-your-first-ethereum-oracle-1ab4cccf0b31)
[Oraclize - blockchain oracle service, enabling data-rich smart contracts](https://provable.xyz/)

Upon startup, 20+ oracles are registered and their assigned indexes are persisted in memory

Update flight status requests from client Dapp result in OracleRequest event emitted by Smart Contract that is captured by server (displays on console and handled in code)

Awesome
Events are correctly emitted and captured, well done :muscle:

Resources
[Deep dive into Ethereum logs](https://codeburst.io/deep-dive-into-ethereum-logs-a8d2047c7371)

Server will loop through all registered oracles, identify those oracles for which the OracleRequest event applies, and respond by calling into FlightSuretyApp contract with random status code of Unknown (0), On Time (10) or Late Airline (20), Late Weather (30), Late Technical (40), or Late Other (50)

Awesome
The server successfully loops through all the status code.

Download DOWNLOAD PROJECT
