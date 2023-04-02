// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Test.sol";
import "../src/Launchpad.sol";
import "../src/rewardToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LaunchpadTest is Test {
    Launchpad launchpad;
    Hashnode hashnode;

    function setUp() public {
        address admin = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;
        // address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        // address controller = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;

        launchpad = new Launchpad();
        hashnode = new Hashnode(admin,20_000_000);

    }

    function test_Launchpad() public {
        address admin = 0x3791dC91d33bC7cc4fBFE033478afa06E2E154Bc;
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        // address cydx = 0x04566666;
        vm.prank(admin);
        hashnode.approve(address(launchpad), 2000000 * 1e18);
        
        launchpad.createIFO(
            100,
            admin,
            address(0x2e234DAe75C793f67A35089C9d99245E1C58470b),
            100 ether,
            0.5 ether,
            2 ether,
            1000000 * 1e18,
            500000 * 1e18,
            100,
            "HashSys",
            "HNSH"
        );

        //DUPLICATE TESTING
        launchpad.createIFO(
            100,
            admin,
            address(0x2e234DAe75C793f67A35089C9d99245E1C58470b),
            100 ether,
            0.5 ether,
            2 ether,
            1000000 * 1e18,
            500000 * 1e18,
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
        launchpad.buyPresale{value: 2 ether}(100);

        vm.deal( address(0x08), 5 ether);
        vm.prank(address(0x08));
        launchpad.buyPresale{value: 2 ether}(100);
        
        // END ICO
        launchpad.endIFO(100);

        //GET BALANCE
        launchpad.getPublicBalance(100);

        //GET TOTAL ETHER RAISED
        launchpad.getTotalEthRaised();

        //GET AMOUNT SUBSCRIBED PER USER
        launchpad.getAmountPerSubscriber(address(0x08), 100);

        // GET DURATION
        launchpad.showDuration();

        // GET PLATFORM SHARE
        launchpad.getPlatformShare(100);

    }

    function test_claimToken() public {
        test_Launchpad();
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;

        vm.prank(user);
        launchpad.claimToken(100);
    }

    function testWithdraw() public {
        test_Launchpad();
        address Controller = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

        uint256 platformBal = launchpad.withdrawToken(Controller, 100, 20000 * 1e18);
        console.log(platformBal);
    }

    function test_Withdraw_Eth() public {
        test_Launchpad();
        address user = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;

        launchpad.withdrawEther( 2 ether ,payable(user));
        console.log(address(launchpad).balance);
        console.log(user.balance);
    }

}