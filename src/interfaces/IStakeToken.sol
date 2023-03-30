// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ICake {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}