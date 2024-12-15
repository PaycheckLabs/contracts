// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.23;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CheckToken is ERC20, ERC20Permit, AccessControl {
    constructor(address defaultAdmin)
        ERC20("Check Token", "CHECK")
        ERC20Permit("Check Token")
    {
        _mint(msg.sender, 100_000_000_000_000_000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }
}
