// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";
import {RaffleConfig} from "./RaffleConfig.s.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract CreateSubscriptionId is Script {
    function createSubscriptionUsingConfig() public returns (uint64) {
        RaffleConfig raffleConfig = new RaffleConfig();
       
        (, address vrfCoordinator, , , ,) =
            raffleConfig.activeNetworkConfig();

        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordination) public returns (uint64) {
        vm.startBroadcast();
        VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordination);
        uint64 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();
        return  subId;
    }

    function run () public returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    function fundSubscriptionUsingConfig() public payable {
        RaffleConfig raffleConfig = new RaffleConfig();
       
        (, address vrfCoordinator, ,uint64 subId , ,address link ) =
            raffleConfig.activeNetworkConfig();

        fundSubscription(vrfCoordinator,subId,link);
    }

    function fundSubscription(address vrfCoordinator,uint64 subId,address linktoken) public  {
            if(block.chainid == 31337){
                vm.startBroadcast();
                 VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId,5 ether);
                vm.stopBroadcast();

            } else {
                vm.startBroadcast();
                LinkToken(linktoken).transferAndCall(vrfCoordinator, 5 ether, abi.encode(subId));
                vm.stopBroadcast();
            }
    }

    function run () public payable {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffle) public {
        RaffleConfig raffleConfig = new RaffleConfig();
       
        (, address vrfCoordinator, ,uint64 subId , , ) =
            raffleConfig.activeNetworkConfig();

        addConsumer(vrfCoordinator,subId,raffle);
    }

    function addConsumer(address vrfCoordinator,uint64 subId,address raffle) public  {
        if(block.chainid == 31337){
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, raffle);
            vm.stopBroadcast();

        } else {
            vm.startBroadcast();
            VRFCoordinatorV2Interface(vrfCoordinator).addConsumer(subId, raffle);
            vm.stopBroadcast();
        }
    }

    function run () public {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(contractAddress);
    }
}