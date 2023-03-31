// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/Launchpad.sol";
import "../src/rewardToken.sol";

contract LaunchpadTest is Test {
    Launchpad launchpad;
    Hashnode hashnode;

    function setUp() public {
        address admin = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        // address controller = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;

        launchpad = new Launchpad();
        hashnode = new Hashnode(admin,20_000_000);

    }

    function test_Launchpad() public {
        address admin = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        address hashN = address(hashnode);

        vm.prank(admin);
        hashnode.approve(address(launchpad), 1000000 * 1e18);
        
        launchpad.createIFO(
            100,
            admin,
            address(0x2e234DAe75C793f67A35089C9d99245E1C58470b),
            100 ether,
            0.5 ether,
            2 ether,
            1000000 * 1e18,
            800000 * 1e18,
            100,
            "HashSys",
            "HNSH"
        );
        hashnode.balanceOf(address(launchpad));
        // start ICO
        launchpad.startIFO(100, 1680421243);

        // BUY ICO TOKEN
        vm.deal(user, 5 ether);
        vm.prank(user);
        launchpad.buyPresale{value: 0.5 ether}(100);
        console.log(user.balance);
        
        // END ICO
        launchpad.endIFO(100);

        //GET BALANCE
        launchpad.getPublicBalance(100);

        //GET TOTAL ETHER RAISED
        launchpad.getTotalEthRaised();

        //GET AMOUNT SUBSCRIBED PER USER
        launchpad.getAmountPerSubscriber(user, 100);

    }

    function test_claimToken() public {
        test_Launchpad();
        address admin = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        address hashN = address(hashnode);
        console.log(address(launchpad));
        vm.prank(user);
        address demo = launchpad.claimToken(100);
        console.log(demo);
    }

    function testWithdraw() public {
        test_Launchpad();
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        uint256 platformBal = launchpad.withdrawToken(user, 100, 500);
        console.log(platformBal);
    }

}