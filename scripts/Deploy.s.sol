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
        // Prepare the bytecode for the CHECK token contract
        bytes memory bytecode = abi.encodePacked(type(CheckToken).creationCode);

        bytes32 salt = bytes32("Check Token");

        // Deploy the contract using CREATE2
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        vm.stopBroadcast();
    }
}