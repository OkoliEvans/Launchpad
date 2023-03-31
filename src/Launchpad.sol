// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import "../";
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
        string tokenName;
        string tokenSymbol;
        bool hasStarted;
        bool maxCapReached;
    }

    mapping(uint32 => IFODetail ) IFODetails_ID;
    mapping(address => mapping(uint32 => uint256)) Amount_per_subscriber;

    address public Controller;
    uint256 public duration;
    uint256 public startTime;
    uint256 endTime;
    uint256 public totalAmountRaised;

    /////////  ERRORS  ///////////

    error notController();
    error IFO_Not_Started();
    error IFO_Already_Started();
    error Amount_less_Than_Minimum_Subscription();
    error Amount_greater_Than_Maximum_Subscription();
    error IFO_Not_Ended();
    error IFO_Not_In_Session();
    error IFO_still_in_progress();
    error Account_Not_Found();
    error Value_cannot_be_empty();
    error IFO_Details_Not_Found();
    error MaxCapReached();
    error Insufficient_Funds();
    error Invalid_Address();

    ////////  EVENTS  /////////

    constructor() {
        Controller = msg.sender;
    }


    ////////   FUNCTIONS  ///////////

    function createIFO(
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
        if(_maxCap <= 0) revert Value_cannot_be_empty();
        if(_token == address(0))revert Value_cannot_be_empty();
        if(_minimumSubscription <= 0) revert Value_cannot_be_empty();
        if(_maximumSubscription <= 0) revert Value_cannot_be_empty();
        if(_tokenTotalSupply <= 0) revert Value_cannot_be_empty();
        if(_publicShare <= 0) revert Value_cannot_be_empty();
        if(_exchangeRate <= 0) revert Value_cannot_be_empty();
        if(_admin == address(0)) revert Value_cannot_be_empty();

        IERC20(_token).transferFrom(_admin, address(this), _tokenTotalSupply);
       
        ifoDetail.id = _id;
        ifoDetail.admin = _admin;
        IFODetails_ID[_id].token = _token;
        ifoDetail.MaxCap = _maxCap;
        ifoDetail.minimumSubscription = _minimumSubscription;
        ifoDetail.maximumSubscription = _maximumSubscription;
        ifoDetail.tokenTotalSupply = _tokenTotalSupply;
        ifoDetail.publicShare = _publicShare;
        ifoDetail.platformShare = _tokenTotalSupply - _publicShare;
        ifoDetail.exchangeRate = _exchangeRate;
        ifoDetail.tokenName = _tokenName;
        ifoDetail.tokenSymbol = _tokenSymbol;
        ifoDetail.hasStarted = false;
        ifoDetail.maxCapReached = false;

    }

    function startIFO(uint32 _id, uint256 _endTime) external {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(msg.sender != Controller) revert notController();
        if (ifoDetail.hasStarted == true) revert IFO_Already_Started();
        if (ifoDetail.id == 0) revert IFO_Details_Not_Found();

        startTime = block.timestamp;
        duration = _endTime - startTime;
        ifoDetail.hasStarted = true;
      
    }

    function showDuration() public view returns(uint256 _duration) {
           _duration = duration;
    }


    function endIFO(uint32 _id) external {
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(msg.sender != Controller) revert notController();
        if (ifoDetail.hasStarted == false) revert IFO_Not_In_Session();
        if (ifoDetail.id == 0) revert IFO_Details_Not_Found();
        if(block.timestamp < endTime) revert IFO_Not_Ended();

        ifoDetail.hasStarted = false;
        // ifoDetail.token = address(0);
        ifoDetail.id = 0;
        ifoDetail.MaxCap = 0;
        ifoDetail.minimumSubscription = 0;
        ifoDetail.maximumSubscription = 0;

        ifoDetail.exchangeRate = 0;
        ifoDetail.tokenName = "";
        ifoDetail.tokenSymbol = "";
        ifoDetail.maxCapReached = false;
    }

    function buyPresale(uint32 _id) external payable {
        uint _amount = msg.value;
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(ifoDetail.hasStarted == false) revert IFO_Not_In_Session();
        if(_amount < ifoDetail.minimumSubscription ) revert Amount_less_Than_Minimum_Subscription();
        if(ifoDetail.maximumSubscription < _amount) revert Amount_greater_Than_Maximum_Subscription();
        if(ifoDetail.maxCapReached) revert MaxCapReached();
        if(ifoDetail.publicShare == 0) revert MaxCapReached();

        // (bool success, ) = address(this).call{value: _amount}("");
        // require(success, "Transaction FAIL...!");
        uint256 xRate = ifoDetail.exchangeRate;
        uint256 amount_bought = _amount * xRate;
        ifoDetail.publicShare -= amount_bought;
        ifoDetail.publicshareBalance += amount_bought;
        Amount_per_subscriber[msg.sender][_id] = amount_bought;
        totalAmountRaised += _amount;

    }

    function getTotalEthRaised() external view returns(uint256){
        return totalAmountRaised;
    }

    function getPublicBalance(uint32 _id) external view returns(uint256){
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        return ifoDetail.publicshareBalance;
    }

    function getAmountPerSubscriber(address _user, uint32 _id) external view returns(uint256) {
        return Amount_per_subscriber[_user][_id];
    }

    function claimToken(uint32 _id) external returns(address tko){
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        require(Amount_per_subscriber[msg.sender][_id] > 0, "No record found");
        if(ifoDetail.hasStarted == true) revert IFO_still_in_progress();

        uint256 _amount = Amount_per_subscriber[msg.sender][_id];
        if(_amount > ifoDetail.publicshareBalance) revert Insufficient_Funds();
        ifoDetail.publicshareBalance -= _amount;
        tko = IFODetails_ID[_id].token;
       IERC20(tko).transfer(msg.sender, _amount);
       Amount_per_subscriber[msg.sender][_id] = 0;
    }

    function withdrawToken(address _to,uint32 _id, uint256 _amount) external returns(uint256) {
        if(msg.sender != Controller) revert notController();
        IFODetail storage ifoDetail = IFODetails_ID[_id];
        if(_to == address(0)) revert Invalid_Address();
        if(_amount > ifoDetail.platformShare) revert Insufficient_Funds();
        IERC20(ifoDetail.token).approve(Controller, _amount);
        IERC20(ifoDetail.token).transferFrom(address(this),_to, _amount);
        ifoDetail.platformShare -= _amount;
        return ifoDetail.platformShare;
    }

    function withdrawEther(uint256 _amount, address payable _to) external payable{
        if(_amount > address(this).balance) revert Insufficient_Funds();
        if(_to == address(0)) revert Invalid_Address();

        (bool success, ) = _to.call{ value: _amount}("");
        require(success, "Failed to send Ether");
    }


    receive() payable external {}
    fallback() payable external {}

}