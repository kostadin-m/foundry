// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {FundFundMe} from "../../script/Interactions.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTests is Test {
    FundMe fundMe;

    address constant USER = address(1);

    function setUp() external {
        console.log(block.number);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function test_fundMe() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundIt(address(payable(fundMe)));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdraw(address(payable(fundMe)));

        assertEq(address(fundMe).balance, 0);
    }
}
