// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IRewardToken.sol";

contract Launchpad {

    struct IFODetail {
        address token;
        uint32 id;
        uint256 minimumSubscription;
        uint256 tokenTotalSupply;
        uint256 publicShare;
        uint256 platformShare;
        string tokenName;
        string tokenSymbol;
        bool hasStarted;
    }

    mapping(address => IFODetail) projectAdmin_To_IFO_details;
    mapping(uint32 => mapping(IFODetail => bool)) IFODetail_Checker;
    mapping(address => mapping(uint32 => uint256)) Subscriber_To_Amount;

    IFODetail[] public ifoDetails;

    address public Controller;
    uint256 public duration = startTime - endTime;
    uint256 public startTime;
    uint256 endTime;

    /////////  ERRORS  ///////////

    error notController();
    error IFO_Not_Started();
    error IFO_Already_Started;
    error Amount_less_Than_Minimum_Amount();
    error IFO_Not_Ended();
    error IFO_Not_In_Session();
    error Account_Not_Found();
    error Value_cannot_be_empty();
    error IFO_Details_Not_Found();

    ////////  EVENTS  /////////


    ////////  INTERNAL FUNCTIONS  ///////////

    function createIFO(IFODetail memory _ifoDetail, uint32 _id) public  {
        if(msg.sender != Controller) revert notController();

        if(
            IFODetail.token == address(0) || 
            IFODetail.tokenTotalSupply == 0 || 
            IFODetail.tokenName == ""
            || IFODetail.tokenSymbol == ""
        ) 
        revert Value_cannot_be_empty();

        if (IFODetail_Checker[_id][_ifoDetail].hasStarted == true) revert IFO_Already_Started();

        Launchpad launchpad = new Launchpad();
        IFODetail storage ifoDetail = _ifoDetail;
        IFODetail.id = 1;
        ifoDetails.push(ifoDetail);

    }

    function startIFO(unit32 _id, IFODetail memory _ifoDetail , uint256 _startTime) public {
        if(msg.sender != Controller) revert notController();
        if (IFODetail_Checker[_id][_ifoDetail].hasStarted == true) revert IFO_Already_Started();
        if (IFODetail.id == 0) revert IFO_Details_Not_Found();

        startTime = _startTime;

        IFODetail_Checker[_id][_ifoDetail].hasStarted = true;
      
    }

    function endIFO(unit32 _id, IFODetail memory _ifoDetail , uint256 _endTime) public {
         if(msg.sender != Controller) revert notController();
        if (IFODetail_Checker[_id][_ifoDetail].hasStarted == false) revert IFO_Not_In_Session();
        if (IFODetail.id == 0) revert IFO_Details_Not_Found();

        endTime = _endTime;

        IFODetail_Checker[_id][_ifoDetail].hasStarted = false;

    }

    function addIFO_ID(uint32 _id) public {

    }

    function buyIFO(uint256 _amount, uint32 _id) public {
        // addIFO_ID();
        if(_amount < IFODetail.minimumSubscription ) revert Amount_less_Than_Minimum_Amount();

        (bool success, ) = address(this).call{value: _amount}("");
        require(success, "Transaction FAIL...!");

        Subscriber_To_Amount[msg.sender][_id] = _amount;
    }

    function updateReturns(uint32 _id) internal returns(uint256 reward) {
        uint256 amount_bought = Subscriber_To_Amount[msg.sender][_id];
        uint32 tokenFormular =  
    }



}