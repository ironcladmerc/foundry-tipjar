// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {Script} from "lib/forge-std/src/Script.sol";
import {TipJar} from "src/TipJar.sol";

contract DeployTipJar is Script {
  function run() external returns (TipJar) {
    TipJar tipJar = new TipJar();
    return tipJar;
  }
}