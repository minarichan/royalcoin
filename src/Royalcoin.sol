// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Royalcoin (XVII)
contract Royalcoin is ERC20 {
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10 ** 18;

    constructor() ERC20("Royalcoin", "XVII") {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
}

