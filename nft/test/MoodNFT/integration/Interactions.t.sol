// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


import {Test,console} from "forge-std/Test.sol";
import {DeployMoodNFT} from "../../../script/DeployMoodNFT.s.sol";
import {MoodNFT} from "../../../src/MoodNFT.sol";
import {MintMoodNFT} from "../../../script/Interactions.s.sol";

contract MoodNFTInteractionsTest is Test {
    DeployMoodNFT deployer;
    MoodNFT moodNFT;

    address test_address = makeAddr('user');

    function setUp() public {
        deployer = new DeployMoodNFT();
        moodNFT = deployer.run();
    }

    function test_canMintWithInteractions () public {
        MintMoodNFT mintMoodNFT = new MintMoodNFT();
        mintMoodNFT.mintNFtOnContarct(address(moodNFT));
    }

        /**
     * @notice This test is to show that the contract can be deployed and then mint on the already deployed contract
     * @dev Make sure to already have a deployed contract in the broadcast deploy a contract via the make-file
     * @dev This test will fail if you do not have a contract deployed already
     * @dev This test will pass if you have a contract deployed already
     */
    function test_canMintWithTheLastDeployedContract () public {
        MintMoodNFT mintMoodNFT = new MintMoodNFT();
        mintMoodNFT.run();
    }
}
