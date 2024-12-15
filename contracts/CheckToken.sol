// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title CheckToken
 * @dev Implementation of the CheckToken by Paycheck Labs
 * 
 * This contract implements the CHECK token - an ERC20 token with permit functionality
 */
contract CheckToken is ERC20, ERC20Permit, ERC20Burnable {
    /// @dev Maximum supply of the token (100 billions)
    uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10**18;

    constructor()
        ERC20("Check Token", "CHECK")
        ERC20Permit("Check Token")
    {
        _mint(msg.sender, MAX_SUPPLY);
    }
}
