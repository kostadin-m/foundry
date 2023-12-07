// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint private s_tokenCounter;
    mapping (uint => string) public s_idToUri;

    constructor() ERC721("DogieNFT", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft (string memory  _tokenUri) external payable {
        uint256 _tokenCounter = s_tokenCounter;

        _tokenCounter += 1;

        s_idToUri[_tokenCounter] = _tokenUri;
        s_tokenCounter = _tokenCounter;

        _safeMint(msg.sender, s_tokenCounter);

    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_idToUri[tokenId];
    }


    function tokenCounter() public view returns (uint) {
        return s_tokenCounter;
    }

}