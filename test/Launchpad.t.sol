// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/Launchpad.sol";
import "../src/rewardToken.sol";

contract LaunchpadTest is Test {
    Launchpad launchpad;
    Hashnode hashnode;

    function test_Launchpad() public {
        launchpad = new Launchpad();
        hashnode = new Hashnode(20_000_000);
        address admin = 0xc6d123c51c7122d0b23e8B6ff7eC10839677684d;
        launchpad.createIFO(
            100,
            admin,
            address(hashnode),
            100 ether,
            0.5 ether,
            2 ether,
            1000000 * 1e18,
            800000 * 1e18,
            100,
            "HashSys",
            "HNSH"
        );

        launchpad.startIFO(100, 1680421243);

        launchpad.endIFO(100);

        launchpad.buyPresale(0.5 ether,102);
    }



}