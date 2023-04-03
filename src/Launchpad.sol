// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


///@author Okoli Evans
///@title  A contract that holds Initial Coin Offerings (ICO), and can handle multiple
///@title  ICOs at once
///@dev  The contract admin oversees registration and creation of vetted projects for ICO,
///@dev  and also monitors the process, and disburses funds at the end of the ICO.
///@notice  An ID is assigned to every ICO created to for efficient tracking of variables changes and
///@notice  updates.


contract Launchpad {

    struct IFODetail {
        address admin;
        address token;
        uint32 id;
        uint256 publicshareBalance;
        uint256 MaxCap;
        uint256 minimumSubscription;
        uint256 maximumSubscription;
        uint256 tokenTotalSupply;
        uint256 publicShare;
        uint256 platformShare;
        uint256 exchangeRate;
        uint256 totalAmountRaised;
        uint256 endTime;
        uint256 startTime; 
        uint256  duration;
        string tokenName;
        string tokenSymbol;
        bool hasStarted;
        bool maxCapReached;
    }

    mapping(uint32 => IFODetail ) IFODetails_ID;
    mapping(address => mapping(uint32 => uint256)) Amount_per_subscriber;

    address public Controller;
    uint256 public GlobaltotalAmountRaised;

    /////////  ERRORS  ///////////

    error notController();
    error IFO_Not_Started();
    error IFO_Already_Started();
    error Amount_less_Than_Minimum_Subscription();
    error Amount_greater_Than_Maximum_Subscription();
    error IFO_Not_Ended();
    error IFO_Not_In_Session();
    error IFO_still_in_progress();
    error Value_cannot_be_empty();
    error IFO_Details_Not_Found();
    error MaxCapReached();
    error Insufficient_Funds();
    error Invalid_Address();
    error ID_Taken_Choose_Another_ID();

    ////////  EVENTS  /////////
    event ICO_Created(uint32 _id, address _token, uint _creation_time);
    event ICO_Started(uint32 _id, uint256 _start_time, uint256 _end_time);
    event BuyPresale(uint32 _id, address _buyer, uint256 _amount);
    event ICO_Ended(uint32 _id, uint256 _endTime);
    event Claim_Token(uint32 _id, address _claimer, uint256 _amount);

    constructor() {
        Controller = msg.sender;
    }


   ////////////////////////////////////////////////////////////////
   ///                                                         ////
   ///                     CORE FUNCTIONS                      ////
   ///                                                         ////
   //////////////////////////////////////////////////////////////// 


    function createICO(
        uint32 _id,
        address _admin,
        address _token,
        uint256 _maxCap,
        uint256 _minimumSubscription,
        uint256 _maximumSubscription,
        uint256 _tokenTotalSupply,
        uint256 _publicShare,
        uint256 _exchangeRate,
        string memory _tokenName,
        string memory _tokenSymbol
        ) external  {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(msg.sender != Controller) revert notController();
        if (ifoDetail.hasStarted == true) revert IFO_Already_Started();
        if(_id <= 0) revert Value_cannot_be_empty();
         if(ifoDetail.id == _id) revert ID_Taken_Choose_Another_ID();
        if(_maxCap <= 0) revert Value_cannot_be_empty();
        if(_token == address(0))revert Value_cannot_be_empty();
        if(_minimumSubscription <= 0) revert Value_cannot_be_empty();
        if(_maximumSubscription <= 0) revert Value_cannot_be_empty();
        if(_tokenTotalSupply <= 0) revert Value_cannot_be_empty();
        if(_publicShare <= 0) revert Value_cannot_be_empty();
        if(_exchangeRate <= 0) revert Value_cannot_be_empty();
        if(_admin == address(0)) revert Value_cannot_be_empty();

        bool success = IERC20(_token).transferFrom(_admin, address(this), _tokenTotalSupply);
        require(success, "Transfer FAIL");
       
        ifoDetail.id = _id;
        ifoDetail.admin = _admin;
        ifoDetail.token = _token;
        ifoDetail.MaxCap = _maxCap;
        ifoDetail.minimumSubscription = _minimumSubscription;
        ifoDetail.maximumSubscription = _maximumSubscription;
        ifoDetail.tokenTotalSupply = _tokenTotalSupply;
        ifoDetail.publicShare = _publicShare;
        ifoDetail.platformShare = _tokenTotalSupply - _publicShare;
        ifoDetail.exchangeRate = _exchangeRate;
        ifoDetail.tokenName = _tokenName;
        ifoDetail.tokenSymbol = _tokenSymbol;

        emit ICO_Created(_id, _token, block.timestamp);

    }

    function startICO(uint32 _id, uint256 _endTime) external {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(msg.sender != Controller) revert notController();
        if (ifoDetail.hasStarted == true) revert IFO_Already_Started();
        if (ifoDetail.id == 0) revert IFO_Details_Not_Found();

        uint256 endTime = (_endTime * 1 minutes);
        ifoDetail.startTime = block.timestamp;
        ifoDetail.endTime = endTime;
        ifoDetail.duration = endTime - ifoDetail.startTime;
        ifoDetail.hasStarted = true;
      
        emit ICO_Started(_id, block.timestamp, endTime / 1 minutes);
    }

    function showDuration(uint32 _id) public view returns(uint256 _duration) {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        _duration = ifoDetail.duration;
    }


    function buyPresale(uint32 _id) external payable {
        uint _amount = msg.value;
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(ifoDetail.hasStarted == false) revert IFO_Not_In_Session();
        if(_amount < ifoDetail.minimumSubscription ) revert Amount_less_Than_Minimum_Subscription();
        if(ifoDetail.maximumSubscription < _amount) revert Amount_greater_Than_Maximum_Subscription();
        if(ifoDetail.maxCapReached) revert MaxCapReached();
        if(ifoDetail.publicShare == 0) revert MaxCapReached();

        uint256 xRate = ifoDetail.exchangeRate;
        uint256 amount_bought = _amount * xRate;
        ifoDetail.publicShare = ifoDetail.publicShare - amount_bought;
        ifoDetail.publicshareBalance = ifoDetail.publicshareBalance + amount_bought;
        Amount_per_subscriber[msg.sender][_id] = Amount_per_subscriber[msg.sender][_id] + amount_bought;
        ifoDetail.totalAmountRaised = ifoDetail.totalAmountRaised + _amount;
        GlobaltotalAmountRaised = GlobaltotalAmountRaised + _amount;
        
        emit BuyPresale(_id, msg.sender, _amount);
    }

    function endICO(uint32 _id) external {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(msg.sender != Controller) revert notController();
        if (ifoDetail.hasStarted == false) revert IFO_Not_In_Session();
        if (ifoDetail.id == 0) revert IFO_Details_Not_Found();
        if(block.timestamp < ifoDetail.endTime) revert IFO_Not_Ended();

        ifoDetail.hasStarted = false;

        // ifoDetail.MaxCap = 0;
        // ifoDetail.minimumSubscription = 0;
        // ifoDetail.maximumSubscription = 0;

        // ifoDetail.exchangeRate = 0;
        // ifoDetail.tokenName = "";
        // ifoDetail.tokenSymbol = "";
        // ifoDetail.maxCapReached = false;
        emit ICO_Ended(_id, block.timestamp / 1 minutes);
    }

    function claimToken(uint32 _id) external {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        require(Amount_per_subscriber[msg.sender][_id] > 0, "No record found");
        if(ifoDetail.hasStarted == true) revert IFO_still_in_progress();

        uint256 _amount = Amount_per_subscriber[msg.sender][_id];
        if(_amount > ifoDetail.publicshareBalance) revert Insufficient_Funds();
        ifoDetail.publicshareBalance = ifoDetail.publicshareBalance - _amount;
       Amount_per_subscriber[msg.sender][_id] = 0;
       IERC20(ifoDetail.token).transfer(msg.sender, _amount);

       emit Claim_Token(_id, msg.sender, _amount);
    }

    function withdrawToken(address _to,uint32 _id, uint256 _amount) external returns(uint256) {
        if(msg.sender != Controller) revert notController();
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(_to == address(0)) revert Invalid_Address();
        if(_amount > ifoDetail.platformShare) revert Insufficient_Funds();
        
        ifoDetail.platformShare = ifoDetail.platformShare - _amount;
        IERC20(ifoDetail.token).transfer(_to, _amount);
        return ifoDetail.platformShare;
    }

    function withdrawEther(uint256 _amount, address _to) external {
        if(msg.sender != Controller) revert notController();
        if(_amount > address(this).balance) revert Insufficient_Funds();
        if(_to == address(0)) revert Invalid_Address();

        (bool success, ) = payable(_to).call{ value: _amount}("");
        require(success, "Failed to send Ether");
    }


    function getTotalEthRaised() external view returns(uint256){
        return GlobaltotalAmountRaised;
    }

    function getPublicBalance(uint32 _id) external view returns(uint256){
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        return ifoDetail.publicshareBalance;
    }

    function getAmountPerSubscriber(address _user, uint32 _id) external view returns(uint256) {
        return Amount_per_subscriber[_user][_id];
    }

    function getPlatformShare(uint32 _id) public view returns(uint256){
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        return ifoDetail.platformShare;
    }

    receive() payable external {}
    fallback() payable external {}

}