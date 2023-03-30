// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract Cake is ERC20 {

    constructor() ERC20("Cake","Cake") {}

}