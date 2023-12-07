// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test,console} from "forge-std/Test.sol";
import {DeployMoodNFT} from "../../../script/DeployMoodNFT.s.sol";
import {MoodNFT} from "../../../src/MoodNFT.sol";
import {TestUtils} from "../../../utils/TestUtils.sol";

contract  moodNFTTest is Test,TestUtils {
    DeployMoodNFT deployer;
    MoodNFT moodNFT;


    
    string expectedSadTokenURI = 'data:/application/json;base64,eyJuYW1lIjogICJNb29kIE5GVCIsICJkZXNjcmlwdGlvbiI6ICJOZnQgdGhhdCByZWZsZWN0cyB0aGUgb3duZXJzIG1vb2QuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6ICAiMTAwIiB9XSwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEQ5NGJXd2dkbVZ5YzJsdmJqMGlNUzR3SWlCemRHRnVaR0ZzYjI1bFBTSnVieUkvUGdvOGMzWm5JSGRwWkhSb1BTSXhNREkwY0hnaUlHaGxhV2RvZEQwaU1UQXlOSEI0SWlCMmFXVjNRbTk0UFNJd0lEQWdNVEF5TkNBeE1ESTBJaUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQZ29nSUR4d1lYUm9JR1pwYkd3OUlpTXpNek1pSUdROUlrMDFNVElnTmpSRE1qWTBMallnTmpRZ05qUWdNalkwTGpZZ05qUWdOVEV5Y3pJd01DNDJJRFEwT0NBME5EZ2dORFE0SURRME9DMHlNREF1TmlBME5EZ3RORFE0VXpjMU9TNDBJRFkwSURVeE1pQTJOSHB0TUNBNE1qQmpMVEl3TlM0MElEQXRNemN5TFRFMk5pNDJMVE0zTWkwek56SnpNVFkyTGpZdE16Y3lJRE0zTWkwek56SWdNemN5SURFMk5pNDJJRE0zTWlBek56SXRNVFkyTGpZZ016Y3lMVE0zTWlBek56SjZJaTgrQ2lBZ1BIQmhkR2dnWm1sc2JEMGlJMFUyUlRaRk5pSWdaRDBpVFRVeE1pQXhOREJqTFRJd05TNDBJREF0TXpjeUlERTJOaTQyTFRNM01pQXpOekp6TVRZMkxqWWdNemN5SURNM01pQXpOeklnTXpjeUxURTJOaTQySURNM01pMHpOekl0TVRZMkxqWXRNemN5TFRNM01pMHpOeko2VFRJNE9DQTBNakZoTkRndU1ERWdORGd1TURFZ01DQXdJREVnT1RZZ01DQTBPQzR3TVNBME9DNHdNU0F3SURBZ01TMDVOaUF3ZW0wek56WWdNamN5YUMwME9DNHhZeTAwTGpJZ01DMDNMamd0TXk0eUxUZ3VNUzAzTGpSRE5qQTBJRFl6Tmk0eElEVTJNaTQxSURVNU55QTFNVElnTlRrM2N5MDVNaTR4SURNNUxqRXRPVFV1T0NBNE9DNDJZeTB1TXlBMExqSXRNeTQ1SURjdU5DMDRMakVnTnk0MFNETTJNR0U0SURnZ01DQXdJREV0T0MwNExqUmpOQzQwTFRnMExqTWdOelF1TlMweE5URXVOaUF4TmpBdE1UVXhMalp6TVRVMUxqWWdOamN1TXlBeE5qQWdNVFV4TGpaaE9DQTRJREFnTUNBeExUZ2dPQzQwZW0weU5DMHlNalJoTkRndU1ERWdORGd1TURFZ01DQXdJREVnTUMwNU5pQTBPQzR3TVNBME9DNHdNU0F3SURBZ01TQXdJRGsyZWlJdlBnb2dJRHh3WVhSb0lHWnBiR3c5SWlNek16TWlJR1E5SWsweU9EZ2dOREl4WVRRNElEUTRJREFnTVNBd0lEazJJREFnTkRnZ05EZ2dNQ0F4SURBdE9UWWdNSHB0TWpJMElERXhNbU10T0RVdU5TQXdMVEUxTlM0MklEWTNMak10TVRZd0lERTFNUzQyWVRnZ09DQXdJREFnTUNBNElEZ3VOR2cwT0M0eFl6UXVNaUF3SURjdU9DMHpMaklnT0M0eExUY3VOQ0F6TGpjdE5Ea3VOU0EwTlM0ekxUZzRMallnT1RVdU9DMDRPQzQyY3preUlETTVMakVnT1RVdU9DQTRPQzQyWXk0eklEUXVNaUF6TGprZ055NDBJRGd1TVNBM0xqUklOalkwWVRnZ09DQXdJREFnTUNBNExUZ3VORU0yTmpjdU5pQTJNREF1TXlBMU9UY3VOU0ExTXpNZ05URXlJRFV6TTNwdE1USTRMVEV4TW1FME9DQTBPQ0F3SURFZ01DQTVOaUF3SURRNElEUTRJREFnTVNBd0xUazJJREI2SWk4K0Nqd3ZjM1puUGdvPSJ9IA==';
    string expectedHappyTokenUri = 'data:/application/json;base64,eyJuYW1lIjogICJNb29kIE5GVCIsICJkZXNjcmlwdGlvbiI6ICJOZnQgdGhhdCByZWZsZWN0cyB0aGUgb3duZXJzIG1vb2QuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6ICAiMCIgfV0sICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIyYVdWM1FtOTRQU0l3SURBZ01qQXdJREl3TUNJZ2QybGtkR2c5SWpRd01DSWdJR2hsYVdkb2REMGlOREF3SWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGdvZ0lEeGphWEpqYkdVZ1kzZzlJakV3TUNJZ1kzazlJakV3TUNJZ1ptbHNiRDBpZVdWc2JHOTNJaUJ5UFNJM09DSWdjM1J5YjJ0bFBTSmliR0ZqYXlJZ2MzUnliMnRsTFhkcFpIUm9QU0l6SWk4K0NpQWdQR2NnWTJ4aGMzTTlJbVY1WlhNaVBnb2dJQ0FnUEdOcGNtTnNaU0JqZUQwaU5qRWlJR041UFNJNE1pSWdjajBpTVRJaUx6NEtJQ0FnSUR4amFYSmpiR1VnWTNnOUlqRXlOeUlnWTNrOUlqZ3lJaUJ5UFNJeE1pSXZQZ29nSUR3dlp6NEtJQ0E4Y0dGMGFDQmtQU0p0TVRNMkxqZ3hJREV4Tmk0MU0yTXVOamtnTWpZdU1UY3ROalF1TVRFZ05ESXRPREV1TlRJdExqY3pJaUJ6ZEhsc1pUMGlabWxzYkRwdWIyNWxPeUJ6ZEhKdmEyVTZJR0pzWVdOck95QnpkSEp2YTJVdGQybGtkR2c2SURNN0lpOCtDand2YzNablBnPT0ifSA=';
    address test_address = makeAddr('user');

    constructor() TestUtils(test_address) {}
 
    function setUp () public {
        deployer = new DeployMoodNFT();
        moodNFT = deployer.run();
    }

    function test_NameIsCorrect() public view {
        string memory nftName = moodNFT.name();
        string memory nftSymbol = moodNFT.symbol();

        string memory expectedName = "Mood NFT";
        string memory expectedSymbol = "MOOD";

        assert(keccak256(abi.encodePacked(nftName)) == keccak256(abi.encodePacked(expectedName)));
        assert(keccak256(abi.encodePacked(nftSymbol)) == keccak256(abi.encodePacked(expectedSymbol)));
    }

    function test_canMintAndHaveABalance() withSingleHoax public {
        moodNFT.mintNft();
        address secondUser = makeAddr("user2");

        uint256 balance = moodNFT.balanceOf(test_address);

        hoax(secondUser, 10 ether);
        moodNFT.mintNft();

        assertEq(moodNFT.balanceOf(test_address),1);
        assertEq(balance, 1);
    }

    function test_TokenBalance () withSingleHoax public {
        moodNFT.mintNft();
        assertEq(moodNFT.tokenCounter(), 1);
    }

    function test_isSadWhenTokenIdIsone () withSingleHoax public {
        moodNFT.mintNft();
        assertEq(uint(moodNFT.s_idToMood(1)), uint(MoodNFT.MOOD.SAD));
    }

    function test_isHappyWhenTokenIdIsTwo () public withPrankAndDealWrapper {
        moodNFT.mintNft();
        moodNFT.mintNft();

        assertEq(uint(moodNFT.s_idToMood(2)), uint(MoodNFT.MOOD.HAPPY));
    }

    function test_canFlipMoods () public withSingleHoax {
        moodNFT.mintNft();

        assertEq(uint(moodNFT.s_idToMood(1)), uint(MoodNFT.MOOD.SAD));

        hoax(test_address, 10 ether);
        moodNFT.flipMood(1);
        assertEq(uint(moodNFT.s_idToMood(1)), uint(MoodNFT.MOOD.HAPPY));
    }

    function test_onlyOwnerCanChangeMoods () public withSingleHoax {
        moodNFT.mintNft();

        hoax(makeAddr("some_other_user"),10 ether);
        vm.expectRevert();
        moodNFT.flipMood(1);

    }

    function test_idToMoodIsTheSameAsGetMood () public withSingleHoax {
        moodNFT.mintNft();
        assertEq(uint(moodNFT.s_idToMood(1)), uint(moodNFT.getMood(1)));
    }

    function test_getMoodReturnsValidMood () public withSingleHoax {
        moodNFT.mintNft();
        assertEq(uint(moodNFT.getMood(1)), uint(MoodNFT.MOOD.SAD));
    }

    function test_getOwnerReturnsValidOwner () public withSingleHoax {
        moodNFT.mintNft();
        assertEq(moodNFT.getOwner(1), test_address);
    }

    function test_ifMoodIsHappyItFlipsToSad () public withPrankAndDealWrapper {
        moodNFT.mintNft();
        moodNFT.mintNft();

        assertEq(uint(moodNFT.getMood(2)), uint(MoodNFT.MOOD.HAPPY));

        moodNFT.flipMood(2);

        assertEq(uint(moodNFT.getMood(2)), uint(MoodNFT.MOOD.SAD));
    }

    function test_ifMoodIsSadItFlipsToHappy () public withPrankAndDealWrapper {
        moodNFT.mintNft();

        assertEq(uint(moodNFT.getMood(1)), uint(MoodNFT.MOOD.SAD));

        moodNFT.flipMood(1);

        assertEq(uint(moodNFT.getMood(1)), uint(MoodNFT.MOOD.HAPPY));
    }

    function test_tokenURI ()  withPrankAndDealWrapper public {
        moodNFT.mintNft();
        moodNFT.mintNft();

        string memory sadUri = moodNFT.tokenURI(1);
        string memory happyUri = moodNFT.tokenURI(2);

        assert(keccak256(abi.encodePacked(happyUri)) == keccak256(abi.encodePacked(expectedHappyTokenUri)));
        assert(keccak256(abi.encodePacked(sadUri)) == keccak256(abi.encodePacked(expectedSadTokenURI)));
    }
}