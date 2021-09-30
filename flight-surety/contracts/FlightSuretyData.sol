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

    struct Airline {   
        address airlineAddress;
        bool isFunded;
    }

    mapping(address => Airline) private airlines;
    uint airlinesCount = 0;

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

    // manage authorization - remove authorizedAppContracts
    // function deauthorizeCaller(address _address) external requireContractOwner {
    //     // TODO: de authorize 
    // }

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline(address _airlineAddress, address _nominatingAirline) external requireAuthorizedAppContracts requireCanRegisterAirline(_nominatingAirline) {
        _registerAirline(_airlineAddress);
    }

    function _registerAirline(address _airlineAddress) internal {
        airlinesCount = airlinesCount.add(1);
        airlines[_airlineAddress].airlineAddress = _airlineAddress;
        airlines[_airlineAddress].isFunded = false;
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy() external payable {}

    /**
     *  @dev Credits payouts to insurees
     */
    function creditInsurees() external pure {}

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay() external pure {}

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
