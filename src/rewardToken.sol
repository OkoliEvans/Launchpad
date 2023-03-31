// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Hashnode is ERC20 {

    constructor(uint256 _amount) ERC20("HashSys","HASH") {
        _mint(address(this), _amount * 1e18);
    }

}




