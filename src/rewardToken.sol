// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Hashnode is ERC20 {

    constructor(address _controller, uint256 _amount) ERC20("HashSys","HNSH") {
        _mint( _controller, _amount * 1e18);
    }

}




