// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address testAddress = makeAddr("some");
    uint256 GAS_PRICE = 1;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(testAddress, 10 ether);
    }

    function test_minimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_priceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function test_fundFailedNoEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function test_fundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(testAddress);
        assertEq(amountFunded, 10e18);
    }

    function test_AddsFunderToArray() public {
        vm.prank(testAddress);

        fundMe.fund{value: 10e18}();
        assertEq(fundMe.getFunder(0), testAddress);
    }

    function test_widthdrawOnlyOwnerShouldRevert() public funded {
        vm.prank(testAddress);
        vm.expectRevert();

        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(testAddress);
        fundMe.fund{value: 10e18}();
        _;
    }

    function test_widthdrawOnlyOwnerShouldSucceed() public funded {
        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(fundMe.getOwner().balance, startingBalance + startingFundMeBalance);
        assertEq(address(fundMe).balance, 0);
    }

    function test_withdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 1e18);
            fundMe.fund{value: 1e18}();
        }

        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(fundMe.getOwner().balance, startingBalance + startingFundMeBalance);
        assertEq(address(fundMe).balance, 0);
    }
}
