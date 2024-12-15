// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.23;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title CheckToken
 * @dev Implementation of the CheckToken by Paycheck Labs
 * 
 * This contract implements the CHECK token - an ERC20 token with permit functionality 
 * and access control features.
 *
 */
contract CheckToken is ERC20, ERC20Permit {

    uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10**18;
    constructor()
        ERC20("Check Token", "CHECK")
        ERC20Permit("Check Token")
    {
        _mint(msg.sender, MAX_SUPPLY);
    }
}
