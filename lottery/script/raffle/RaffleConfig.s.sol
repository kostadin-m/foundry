// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";

contract RaffleConfig is Script {
    error Script_InvalidChainId();

    struct Config {
        bytes32 gasLane;
        address vrfCoordinator;
        uint32 callbackGasLimit;
        uint64 subscriptionId;
        uint256 entranceFee;
        address link;
    }

    Config public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = gethMainnetEthConfig();
        } else {
            activeNetworkConfig = getCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (Config memory) {
        return Config({
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            subscriptionId: 7178,
            callbackGasLimit: 500000,
            entranceFee: 0.0005 ether,
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function gethMainnetEthConfig() public pure returns (Config memory) {
        return Config({
            vrfCoordinator: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
            gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
            subscriptionId: 7178,
            callbackGasLimit: 500000,
            entranceFee: 0.1 ether,
            link:0x514910771AF9Ca656af840dff83E8264EcF986CA
        });
    }

    function getCreateAnvilEthConfig() public returns (Config memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);

        LinkToken linkToken = new LinkToken();

        vm.stopBroadcast();

        return Config({
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            entranceFee: 0.1 ether,
            link: address(linkToken)
        });
    }
}
