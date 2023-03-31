// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Launchpad.sol";
import "../src/rewardToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract DeployScript is Script {
    Launchpad launchpad;
    Hashnode hashnode;

    function run() public {
        address deployer = 0xc6d123c51c7122d0b23e8B6ff7eC10839677684d;
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        vm.broadcast();

        launchpad = new Launchpad();
        hashnode = new Hashnode(deployer,20_000_000);

    }
}
