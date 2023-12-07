// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../../src/BasicNFT.sol";
import {TestUtils} from "../../../utils/TestUtils.sol";

contract  BasicNFTTest is Test,TestUtils {
    DeployBasicNFT deployer;
    BasicNFT basicNFT;

    address test_address = makeAddr('user');

    constructor() TestUtils(test_address) {}

    function setUp () public {
        deployer = new DeployBasicNFT();
        basicNFT = deployer.run();
    }

    function test_NameIsCorrect() public view {
        string memory nftName = basicNFT.name();
        string memory nftSymbol = basicNFT.symbol();


        string memory expectedName = "DogieNFT";
        string memory expectedSymbol = "DOG";

        assert(keccak256(abi.encodePacked(nftName)) == keccak256(abi.encodePacked(expectedName)));
        assert(keccak256(abi.encodePacked(nftSymbol)) == keccak256(abi.encodePacked(expectedSymbol)));
    }

    function test_canMintAndHaveABalance() withSingleHoax public {
        basicNFT.mintNft("https://ipfs.io/ipfs/QmbVH9gyqCpK639drfh9k1TqsrdUZowRgFWoRWUj37MYs7");
        uint256 balance = basicNFT.balanceOf(test_address);

        address someUser = makeAddr("other_user");

        hoax(someUser, 10 ether);
        basicNFT.mintNft("https://ipfs.io/ipfs/QmbVH9gyqCpK639drfh9k1TqsrdUZowRgFWoRWUj37MYs7");

        assertEq(basicNFT.balanceOf(someUser),1);
        assertEq(balance, 1);
    }

    function testTokenBalance () public withPrankAndDealWrapper {
        basicNFT.mintNft("https://ipfs.io/ipfs/QmbVH9gyqCpK639drfh9k1TqsrdUZowRgFWoRWUj37MYs7");
        assertEq(basicNFT.tokenCounter(), 1);
    }

    function test_tokenURI () public withPrankAndDealWrapper {
        string memory expectedtokenURI = "https://ipfs.io/ipfs/QmbVH9gyqCpK639drfh9k1TqsrdUZowRgFWoRWUj37MYs7";

        basicNFT.mintNft(expectedtokenURI);
        string memory tokenURI = basicNFT.tokenURI(1);

        assert(keccak256(abi.encodePacked(tokenURI)) == keccak256(abi.encodePacked(expectedtokenURI)));
    }
}