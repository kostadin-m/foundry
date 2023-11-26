// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/**
 * @title Raffle
 * @author web3km
 * @notice This contract is used to create a raffle
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2 {
    error Raffle_NotEnoughSend();
    error Raffle_IntervalNotPassed(uint256 _interval);
    error Raffle_RequestNotFound();
    error Raffle_FailedToSend();
    error Raffle_NotOpened();
    error Raffle_DuplicateAddress();

    event RequestSent(uint256 indexed requestId);

    enum RaffleStatus {
        OPENED,
        CLOSED
    }

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWord;
    }

    // @dev The interval in seconds between raffles
    uint256 private immutable i_interval;
    uint64 private immutable i_subscriptionId;
    uint256 private immutable i_entranceFee;
    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_keyhash;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    uint32 private constant CALLBACK_GAS_LIMIT = 100000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint8 private constant NUM_WORDS = 1;

    uint256 private s_lastTimeStamp;
    address payable[] private s_players;
    address private s_recentWinner;
    RaffleStatus private s_raffleStatus;
    mapping(uint256 => RequestStatus) private s_requests;

    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner, uint256 indexed requestId);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyhash,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        s_lastTimeStamp = block.timestamp;
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        i_subscriptionId = _subscriptionId;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_keyhash = _keyhash;
        s_raffleStatus = RaffleStatus.OPENED;
        i_callbackGasLimit = _callbackGasLimit;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) revert Raffle_NotEnoughSend();
        if (s_raffleStatus == RaffleStatus.CLOSED) revert Raffle_NotOpened();

        address payable[] memory players = s_players;

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) revert Raffle_DuplicateAddress();
        }

        emit EnteredRaffle(msg.sender);

        s_players.push(payable(msg.sender));
    }

    /**
     * @dev this is the function that the chainlink automation nodes call to see if its time to perform an upkeep
     * The following should be true if
     * 1. The time interval has passed
     * 2. The raffle is in OPEN status
     * 3. The contract has ETH (aka players)
     * 4. The subscription must be funded with link
     */
    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        bool isOpen = s_raffleStatus == RaffleStatus.OPENED;

        upkeepNeeded = (hasBalance && isOpen && timeHasPassed && hasPlayers);

        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        (bool upKeedNeeded,) = checkUpkeep("0x0");
        if (!upKeedNeeded) revert Raffle_IntervalNotPassed(i_interval);

        s_raffleStatus = RaffleStatus.CLOSED;

         uint256 reqId = i_vrfCoordinator.requestRandomWords(
            i_keyhash, i_subscriptionId, REQUEST_CONFIRMATIONS, CALLBACK_GAS_LIMIT, NUM_WORDS
        );

        s_requests[reqId].exists = true;

        emit RequestSent(reqId);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        if (!s_requests[_requestId].exists) revert Raffle_RequestNotFound();

        s_requests[_requestId].exists = true;

        uint256 indexOfWinner = _randomWords[0] % s_players.length;

        address payable winner = s_players[indexOfWinner];

        s_recentWinner = winner;
        s_raffleStatus = RaffleStatus.OPENED;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        emit WinnerPicked(winner, _requestId);

        (bool success,) = winner.call{value: address(this).balance}("");

        if (!success) revert Raffle_FailedToSend();
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayerCount() external view returns (uint256) {
        return s_players.length;
    }

    function getState() external view returns (RaffleStatus) {
        return s_raffleStatus;
    }

    function getPlayerByIndex(uint256 _index) external view returns (address) {
        return s_players[_index];
    }

    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getInterval() external view returns (uint256) {
        return i_interval;
    }
}
