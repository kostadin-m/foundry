// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


import {Test,console} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../../src/BasicNFT.sol";
import {MintBasicNFT} from "../../../script/Interactions.s.sol";

contract BasicNFTInteractionsTest is Test {
    DeployBasicNFT deployer;
    BasicNFT basicNFT;

    address test_address = makeAddr('user');

    function setUp() public {
        deployer = new DeployBasicNFT();
        basicNFT = deployer.run();
    }

    function test_canMintWithInteractions () public {
        MintBasicNFT mintBasicNFT = new MintBasicNFT();
        mintBasicNFT.mintNFtOnContarct(address(basicNFT));
    }

    /**
     * @notice This test is to show that the contract can be deployed and then mint on the already deployed contract
     * @dev Make sure to already have a deployed contract in the broadcast deploy a contract via the make-file
     * @dev This test will fail if you do not have a contract deployed already
     * @dev This test will pass if you have a contract deployed already
     */
    function test_canMintOnLastlyDeployedContract () public {
        MintBasicNFT mintBasicNFT = new MintBasicNFT();
        mintBasicNFT.run();
    }
}
