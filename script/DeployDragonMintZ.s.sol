// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DragonMintZ} from "../src/DragonMintZ.sol";

contract DeployDragonMintZ is Script {
    function run() external returns (DragonMintZ) {
        string memory baseURI = vm.envString("BASE_URI");

        vm.startBroadcast();
        DragonMintZ dragonMintZ = new DragonMintZ(baseURI);
        console.log("Created a new DragonMintZ contract!");
        console.logAddress(address(dragonMintZ));
        vm.stopBroadcast();

        return dragonMintZ;
    }
}
