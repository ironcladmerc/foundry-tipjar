// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import "ds-test/test.sol";
import "script/DeployTipJar.s.sol";
import "src/TipJar.sol";
import "lib/forge-std/src/Vm.sol";

contract DeployTipJarTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);
    DeployTipJar deployScript;

    function setUp() public {
        deployScript = new DeployTipJar();
    }

    function testDeployTipJar() public {
        // Simulate running the script
        vm.startBroadcast();
        TipJar deployedTipJar = deployScript.run();
        vm.stopBroadcast();

        // Verify that the TipJar contract is deployed
        assertTrue(
            address(deployedTipJar) != address(0),
            "TipJar deployment failed"
        );

        // Further tests can be added here to verify the correct initialization
        // and functionality of the deployed TipJar contract
    }
}
