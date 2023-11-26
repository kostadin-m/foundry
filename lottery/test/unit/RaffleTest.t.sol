// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/raffle/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {RaffleConfig} from "../../script/raffle/RaffleConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    DeployRaffle deployer;
    Raffle raffle;
    RaffleConfig raffleConfig;
    address vrfCoordinator;

    event EnteredRaffle(address indexed player);

    function setUp() public {
        deployer = new DeployRaffle();
        (raffle, raffleConfig) = deployer.run();
                (, address vrf, , , ,) =
            raffleConfig.activeNetworkConfig();

        vrfCoordinator = vrf;
    }

    function test_raffleInitializesInOpenState() public view {
        assert(raffle.getState() == Raffle.RaffleStatus.OPENED);
    }

    function test_raffleRevertsWithLessValue() public {
        uint256 etherFromUser = 0.00005 ether;

        vm.expectRevert(Raffle.Raffle_NotEnoughSend.selector);
        raffle.enterRaffle{value: etherFromUser}();
    }

    function test_raffleEnterWithValidValue() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        assertEq(paidByPlayer, raffle.getTotalBalance());
    }

    function test_raffleUserGetsStoredInStorage () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        address mockAddress = makeAddr('someUser');

        hoax(mockAddress,20 ether);
        raffle.enterRaffle{value: paidByPlayer}();

        assertEq(raffle.getPlayerByIndex(0), mockAddress);
        assertEq(raffle.getPlayerCount(), 1);
    }

    /**
     * @notice This contract is used to create a raffle
     * @dev If the same player tries to join the raffle again, the transaction will revert
     */
    function test_revertsWhenTheSameUserEntersTwice() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.expectRevert();
        raffle.enterRaffle{value: paidByPlayer}();
    }

    function test_raffleSucceedsWithMultipleUsers() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        uint256 USER_COUNT = 100;

        for (uint256 i = 0; i < USER_COUNT; i++) {
            address convertedAddress = address(uint160(i));
            hoax(convertedAddress, paidByPlayer);
            raffle.enterRaffle{value: paidByPlayer}();
        }
        assertEq(raffle.getPlayerCount(), USER_COUNT);
        assertEq(paidByPlayer * USER_COUNT, raffle.getTotalBalance());
    }

    function test_raffleRevertsIfTheSameUserEnters() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;
        uint256 USER_COUNT = 100;

        raffle.enterRaffle{value: paidByPlayer}();

        for (uint256 i = 0; i < USER_COUNT; i++) {
            vm.expectRevert();
            raffle.enterRaffle{value: paidByPlayer}();
        }

        assertEq(raffle.getPlayerCount(), 1);
        assertEq(paidByPlayer, raffle.getTotalBalance());
    }

    function test_cantEnterWhenRaffleIsClosed () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        raffle.performUpkeep("0x0");

        vm.expectRevert(Raffle.Raffle_NotOpened.selector);
        raffle.enterRaffle{value: paidByPlayer}();
    }

    function test_emitsEventOnEntrance() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        address mockAddress = makeAddr('someUser');

        vm.expectEmit(true,false,false,false,address(raffle));
        emit EnteredRaffle(mockAddress);

        hoax(mockAddress,20 ether);
        raffle.enterRaffle{value: paidByPlayer}();

        assertEq(raffle.getPlayerCount(), 1);
    }

    function test_checkUpKeepReturnsFalseWithNoBalance() public {
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );

        (bool upkeepNeeded,) = raffle.checkUpkeep("0x0");


        assert(!upkeepNeeded);
    }

    function test_checkUpKeepReturnsFalseIfRaffleIsntOpen () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        raffle.performUpkeep("0x0");

        (bool upkeepNeeded,) = raffle.checkUpkeep("0x0");

        assert(!upkeepNeeded);
    }

    function test_performUpkeepRevertsIfCheckUpkeepReturnsFalse() public {
        vm.expectRevert();
        raffle.performUpkeep("0x0");
    }

    function test_checkUpKeepReturnsFalseIfTimeHasntPassed() public {
        vm.warp(block.timestamp + raffle.getInterval()   - 4);
        vm.roll(block.number + 1 );
        (bool upKepNeeded,) = raffle.checkUpkeep("0x0");

        assert(!upKepNeeded);
    }

    function test_CheckupKeepReturnsTrueIfConditionsAreMet() public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        (bool upKepNeeded,) = raffle.checkUpkeep("0x0");

        assert(upKepNeeded);
    }


    function test_performUpKeepRevertsIfThereisNoBalance () public {
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        vm.expectRevert();
        raffle.performUpkeep("0x0");
    }

    function test_performUpKeepRevertsIfTimeHasntPassed () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() - 1);
        vm.roll(block.number + 1 );
        vm.expectRevert();
        raffle.performUpkeep("0x0");
    }

    function test_performUpKeepPassesWhenConditionsAreMet () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        raffle.performUpkeep("0x0");
    }

    function test_emitsEventWithRequestId () public {
        uint256 paidByPlayer = raffle.getEntranceFee() * 2;

        raffle.enterRaffle{value: paidByPlayer}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        vm.recordLogs();
        raffle.performUpkeep("0x0");

        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleStatus rStatus = raffle.getState();


        assert(uint256(requestId) > 0);
        assert(rStatus == Raffle.RaffleStatus.CLOSED);
    }

    function  test_fullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep (uint256 randomReqId) public {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomReqId, address(raffle));
    }

    function test_fullfillRandomWordsPicksAWinnerResetsAndSendsMoney() public {
        uint256 paidByPlayer = raffle.getEntranceFee();

        uint256 USER_COUNT = 5;


        for (uint256 i = 0; i < USER_COUNT; i++) {
            address convertedAddress = address(uint160(i));
            hoax(convertedAddress, paidByPlayer);
            raffle.enterRaffle{value: paidByPlayer}();
            // vm.expectEmit(true,false,false,false,address(raffle));
            // emit EnteredRaffle(convertedAddress);
        }

        vm.recordLogs();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1 );
        raffle.performUpkeep("0x0");

        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 reqId = entries[1].topics[1];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(reqId), address(raffle));

        assert(raffle.getPlayerCount() == 0);
        assert(raffle.getRecentWinner().balance == USER_COUNT * paidByPlayer);
        assert(raffle.getTotalBalance() == 0);
        assert(raffle.getState() == Raffle.RaffleStatus.OPENED);
    }
}
