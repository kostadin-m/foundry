// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../../src/Raffle.sol";
import {RaffleConfig} from "./RaffleConfig.s.sol";
import {CreateSubscriptionId,FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public returns (Raffle,RaffleConfig) {
        RaffleConfig raffleConfig = new RaffleConfig();
        uint256 weekInSeconds = 60;
        (bytes32 gasLane, address vrfCoordinator, uint32 callBackGasLimit, uint64 subscriptionId, uint256 entranceFee,address link) =
            raffleConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscriptionId createSubscriptionId = new CreateSubscriptionId();
            subscriptionId = createSubscriptionId.createSubscription(vrfCoordinator);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator,subscriptionId,link);

        }

        vm.startBroadcast();
        Raffle raffle =
            new Raffle(entranceFee, weekInSeconds, subscriptionId, vrfCoordinator, gasLane, callBackGasLimit);
        vm.stopBroadcast();

           
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinator,subscriptionId, address(raffle));

        return (raffle,raffleConfig);
    }
}
