// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title MerkleAirdrop for Royalcoin (XVII)
contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    bytes32 public immutable merkleRoot;
    mapping(address => bool) public hasClaimed;

    event Claimed(address indexed account, uint256 amount);

    error AlreadyClaimed();
    error InvalidProof();

    constructor(IERC20 _token, bytes32 _merkleRoot) {
        token = _token;
        merkleRoot = _merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof) external {
        if (hasClaimed[account]) revert AlreadyClaimed();

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(proof, merkleRoot, leaf)) revert InvalidProof();

        hasClaimed[account] = true;
        // MerkleProof.verify is an internal library call, not an external call (lint false positive).
        // forge-lint: disable-next-line(reentrancy-events)
        emit Claimed(account, amount);
        token.safeTransfer(account, amount);
    }
}
