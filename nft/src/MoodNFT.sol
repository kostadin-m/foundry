// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/Test.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    using Base64 for bytes;

    error MoodNFT_OnlyOwnerCanChangeMoods();

    enum MOOD {
        HAPPY,
        SAD 
    }

    uint private s_tokenCounter;
    mapping (uint => MOOD) public s_idToMood;
    mapping (uint => address) public s_idToOwner;

    string private  s_sadSvgImageUri;
    string private  s_happySvgImageUri;


    constructor(string memory _sadImageUri, string memory _happyImageUri) ERC721("Mood NFT", "MOOD") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = _sadImageUri;
        s_happySvgImageUri = _happyImageUri;
    }

    function flipMood (uint256 tokenNumber) external {
        if(getOwner(tokenNumber) != msg.sender) revert MoodNFT_OnlyOwnerCanChangeMoods();

        MOOD mood = getMood(tokenNumber);

        if(mood == MOOD.HAPPY) {
            s_idToMood[tokenNumber] = MOOD.SAD;
        } else {
            s_idToMood[tokenNumber] = MOOD.HAPPY;
        }
    }

    function mintNft ()  external payable {
        uint256 _tokenCounter = s_tokenCounter;

        _tokenCounter++;
        s_tokenCounter = _tokenCounter;

        MOOD mood = _tokenCounter % 2 == 0 ? MOOD.HAPPY : MOOD.SAD;

        s_idToOwner[_tokenCounter] = msg.sender;
        s_idToMood[_tokenCounter] = mood;

        _safeMint(msg.sender, s_tokenCounter);

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        MOOD mood = getMood(tokenId);

        string memory imageURI = mood == MOOD.HAPPY ? s_happySvgImageUri : s_sadSvgImageUri;

        string memory moodiness = mood == MOOD.HAPPY ? "0" : "100";

        console.log("moodiness: ", moodiness);

        return string(abi.encodePacked(_baseURI(), Base64.encode(bytes(abi.encodePacked(
            '{"name":  "', name(), '", "description": "Nft that reflects the owners mood.", "attributes": [{"trait_type": "moodiness", "value":  "', moodiness ,'" }], "image": "', imageURI, '"} '
        )))));

    }   

    function getMood (uint256 tokenId) public view returns (MOOD) {
        return s_idToMood[tokenId];
    }

    function tokenCounter() public view returns (uint) {
        return s_tokenCounter;
    }

    function _baseURI () internal pure override returns (string memory) {
        return "data:/application/json;base64,";
    }

   function getOwner (uint256 tokenId) public view returns (address) {
       return s_idToOwner[tokenId];
    }

}