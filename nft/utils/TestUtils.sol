//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


import {Test} from "forge-std/Test.sol";

contract TestUtils is Test {
    address immutable i_test_address;

    constructor (address test_address) {
        i_test_address = test_address;      
    }

        modifier withSingleHoax {
        hoax(i_test_address, 10 ether);
        _;
    }

    modifier withPrankAndDealWrapper {
        vm.startPrank(i_test_address);
        vm.deal(i_test_address, 10 ether);
        _;
        vm.stopPrank();
    }
}