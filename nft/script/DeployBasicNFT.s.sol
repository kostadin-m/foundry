// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "@devops/DevOpsTools.sol";
import {BasicNFT} from "../src/BasicNFT.sol";

contract DeployBasicNFT is Script {
    uint256 deployerKey;

    function run() public returns (BasicNFT) {
        vm.startBroadcast();
        BasicNFT basicNFT = new BasicNFT();
        vm.stopBroadcast();
        return basicNFT;

    }
}