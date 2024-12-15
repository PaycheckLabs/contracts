// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/CheckToken.sol";
import 'forge-std/Script.sol';

contract DeployCheckWithCreate2 is Script {
    /**
     * @dev Deploys the CHECK token contract using CREATE2.
     * @return addr The address of the deployed contract.
     */
    function run() external returns (address addr) {
        vm.startBroadcast();
        
        CheckToken checkToken = new CheckToken();
        addr = address(checkToken);

        vm.stopBroadcast();
    }
}