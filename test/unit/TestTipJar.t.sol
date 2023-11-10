// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {DeployTipJar} from "script/DeployTipJar.s.sol";
import {TipJar} from "src/TipJar.sol";

contract TestTipJar is Test {
  TipJar tipJar;

  address public USER = makeAddr("user");
  address public DONOR = makeAddr("donor");

  uint256 public constant STARTING_BALANCE = 10 ether;

  function setUp() external {
    DeployTipJar deployer = new DeployTipJar();
    tipJar = deployer.run();

    vm.deal(DONOR, STARTING_BALANCE);
    vm.deal(USER, STARTING_BALANCE);
  }
}