// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {CheckToken} from "contracts/CheckToken.sol";

contract CheckTokenTest is Test {
  CheckToken public instance;

  function setUp() public {
    instance = new CheckToken();
  }

  function testName() public view {
    assertEq(instance.name(), "Check Token");
  }
}
