// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {CheckToken} from "src/CheckToken.sol";

contract CheckTokenTest is Test {
  CheckToken public instance;

  function setUp() public {
    address defaultAdmin = vm.addr(1);
    instance = new CheckToken(defaultAdmin);
  }

  function testName() public view {
    assertEq(instance.name(), "Check Token");
  }
}
