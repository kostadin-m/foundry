// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "@devops/DevOpsTools.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {MoodNFT} from "../src/MoodNFT.sol";

contract MintBasicNFT is Script {
    string  public TOKEN_URI = "https://ipfs.io/ipfs/QmcoaQV69NAUKsWAEd7nECcoEXau3a2jZp21K1spYHZzNF";

    function mintNFtOnContarct (address contractAddress) public {
        vm.startBroadcast();
        BasicNFT(contractAddress).mintNft(TOKEN_URI);
        vm.stopBroadcast();
    }

    function run () public  returns(BasicNFT){
       address mostRecentlyDeployeed = DevOpsTools.get_most_recent_deployment("BasicNFT", block.chainid );
       mintNFtOnContarct(mostRecentlyDeployeed);

              return BasicNFT(mostRecentlyDeployeed);
    }

}

contract MintMoodNFT is Script {

    function mintNFtOnContarct (address contractAddress) public {
        vm.startBroadcast();
        MoodNFT(contractAddress).mintNft();
        vm.stopBroadcast();
    }

    function run () public returns (MoodNFT) {
       address mostRecentlyDeployeed = DevOpsTools.get_most_recent_deployment("MoodNFT", block.chainid );
       mintNFtOnContarct(mostRecentlyDeployeed);

       return MoodNFT(mostRecentlyDeployeed);
    }

}

