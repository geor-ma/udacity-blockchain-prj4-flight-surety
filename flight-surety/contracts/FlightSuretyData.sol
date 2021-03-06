// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.7.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner; // Account used to deploy contract
    bool private operational = true; // Blocks all state changes throughout the contract if false

    address[] private authorizedAppContracts;

    struct Passenger {
        address passengerAccountAddress;
        uint8 flightNumber;
        uint purchasedInsuranceAmount;
        uint creditedInsuranceAmount; // insurance credit when flight is delayed
    }

    mapping(address => Passenger) private passengers;

    struct Airline {   
        address airlineAddress;
        bool isFunded;
        bool isRegistered; //set to true when all conditions to register meets
        uint approvalVotes; // number of approval votes by existing airlines for this airline. used when no. of airlines is > 4
    }

    mapping(address => Airline) private airlines;
    uint airlinesCount = 0;

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airlineAddress;
        uint8 flightNumber;
    }
    mapping(uint8 => Flight) private flights;
    uint8[] private flightNumbers;

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor(address firstAirline) public {
        contractOwner = msg.sender;
        _registerAirline(firstAirline);
        airlines[firstAirline].isFunded = true;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
     * @dev Modifier that requires the "operational" boolean variable to be "true"
     *      This is used on all state changing functions to pause the contract in
     *      the event there is an issue that needs to be fixed
     */
    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
     * @dev Modifier that requires the an Authorized AppContract account to be the function caller
     */
    modifier requireAuthorizedAppContracts() {
        bool isAuthorizedAppContract = false;

        //loop through authorized app contracts to find if caller is authorized
        for (uint i=0; i < authorizedAppContracts.length; i++){
            if(authorizedAppContracts[i] == msg.sender){
                isAuthorizedAppContract = true;
                break;
            }
        }

        require(isAuthorizedAppContract, "Caller is not an authorized app.");
        _;
    }

    /**
     * @dev Modifier that requires - If airlines count < 5, only existing airlines can register new airline
     */
    modifier requireCanRegisterAirline(address nominatingAirline) {
        bool canRegister = false;

        //If airlines count < 5, only existing airlines can register new airline
        if( airlinesCount < 5) {
            if(airlines[nominatingAirline].airlineAddress == nominatingAirline ){
                canRegister = true;
            }
        }
        else{ 
            canRegister = true;
        }

        require(canRegister, "Caller cannot register new airline.");
        _;
    }
    


    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Get operating status of contract
     *
     * @return A bool that is the current operating status
     */
    function isOperational() public view returns (bool) {
        return operational;
    }

    /**
     * @dev Sets contract operations on/off
     *
     * When operational mode is disabled, all write transactions except for this one will fail
     */
    function setOperatingStatus(bool mode) external requireContractOwner {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    // manage authorization - add to authorizedAppContracts
    function authorizeCaller(address _address) external requireContractOwner {
        authorizedAppContracts.push(_address);
    }

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline(address _airlineToRegister, address _nominatingAirline) external requireAuthorizedAppContracts requireCanRegisterAirline(_nominatingAirline) {
        require(airlines[_nominatingAirline].isFunded == true, "nominating airline needs to be funded to register other airline." );
        _registerAirline(_airlineToRegister);
    }

    function _registerAirline(address _airlineToRegister) internal {
        airlinesCount = airlinesCount.add(1);
        airlines[_airlineToRegister].airlineAddress = _airlineToRegister;
        airlines[_airlineToRegister].isFunded = false;
        airlines[_airlineToRegister].approvalVotes = 1; //default to 1 as it is safe to consider the nominating airline has approved
        if( airlinesCount < 5){
            airlines[_airlineToRegister].isRegistered = true;
        }
    }

    function approveAirlineRegistration(address _airlineToRegister, address _approvingAirline) external requireAuthorizedAppContracts{
        require((airlines[_approvingAirline].airlineAddress == _approvingAirline) && (airlines[_approvingAirline].isRegistered == true), "Caller cannot register new airline.");
        airlines[_airlineToRegister].approvalVotes = airlines[_airlineToRegister].approvalVotes + 1; 
        if(airlines[_airlineToRegister].approvalVotes >= 2){
            airlines[_airlineToRegister].isRegistered = true;
        }
    }

    function registerFlight(uint8 _flightNumber, address _airlineAddress) external requireAuthorizedAppContracts{
        require((airlines[_airlineAddress].airlineAddress == _airlineAddress) && (airlines[_airlineAddress].isRegistered == true), "Only a registered airline can register a flight.");

        flights[_flightNumber].flightNumber = _flightNumber;
        flights[_flightNumber].airlineAddress = _airlineAddress;
        flights[_flightNumber].isRegistered = true;

        flightNumbers.push(_flightNumber);

    }

    function getFlights() external view requireAuthorizedAppContracts returns (uint8[] memory) {
        return flightNumbers;
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy(address _passengerAccountNumber, uint8 _flightNumber, uint _insuranceAmount) external requireAuthorizedAppContracts payable {
        require(_insuranceAmount <= 1, "Purchase limit is upto 1.");

        passengers[_passengerAccountNumber].passengerAccountAddress = _passengerAccountNumber;
        passengers[_passengerAccountNumber].flightNumber = _flightNumber;
        passengers[_passengerAccountNumber].purchasedInsuranceAmount = _insuranceAmount;
        passengers[_passengerAccountNumber].creditedInsuranceAmount = 0;
    }

    /**
     *  @dev Credits payouts to insurees
     */
    // function creditInsurees() external pure {
    //     uint x = uint(1) * uint(1.5);
    // }

    function creditInsurees(address _passengerAddress) external requireAuthorizedAppContracts {
        //set the credit amount to 1.5 times of purchased insurance amount
        uint insuranceAmount = passengers[_passengerAddress].purchasedInsuranceAmount.mul(uint(150)).div(uint(100));
        passengers[_passengerAddress].creditedInsuranceAmount = insuranceAmount;
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay(address payable _passengerAddress) external payable requireAuthorizedAppContracts {
        uint paymentAmount = passengers[_passengerAddress].creditedInsuranceAmount;
        passengers[_passengerAddress].creditedInsuranceAmount = 0;
        _passengerAddress.transfer(paymentAmount);
    }

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fund() public payable {}

    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
     * @dev Fallback function for funding smart contract.
     *
     */
    function() external payable {
        fund();
    }
}
