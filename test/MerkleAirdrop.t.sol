// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Royalcoin} from "../src/Royalcoin.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract MerkleAirdropTest is Test {
    Royalcoin token;
    MerkleAirdrop airdrop;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");
    address dave = makeAddr("dave");
    address mallory = makeAddr("mallory");

    uint256 constant ALICE_AMOUNT = 100 ether;
    uint256 constant BOB_AMOUNT = 200 ether;
    uint256 constant CAROL_AMOUNT = 300 ether;
    uint256 constant DAVE_AMOUNT = 400 ether;

    bytes32 leafAlice;
    bytes32 leafBob;
    bytes32 leafCarol;
    bytes32 leafDave;
    bytes32 nodeAB;
    bytes32 nodeCD;
    bytes32 root;

    function _leaf(address account, uint256 amount) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encode(a, b)) : keccak256(abi.encode(b, a));
    }

    function setUp() public {
        leafAlice = _leaf(alice, ALICE_AMOUNT);
        leafBob = _leaf(bob, BOB_AMOUNT);
        leafCarol = _leaf(carol, CAROL_AMOUNT);
        leafDave = _leaf(dave, DAVE_AMOUNT);
        nodeAB = _hashPair(leafAlice, leafBob);
        nodeCD = _hashPair(leafCarol, leafDave);
        root = _hashPair(nodeAB, nodeCD);

        token = new Royalcoin();
        airdrop = new MerkleAirdrop(token, root);

        token.transfer(address(airdrop), ALICE_AMOUNT + BOB_AMOUNT + CAROL_AMOUNT + DAVE_AMOUNT);
    }

    function _proofAlice() internal view returns (bytes32[] memory proof) {
        proof = new bytes32[](2);
        proof[0] = leafBob;
        proof[1] = nodeCD;
    }

    function _proofCarol() internal view returns (bytes32[] memory proof) {
        proof = new bytes32[](2);
        proof[0] = leafDave;
        proof[1] = nodeAB;
    }

    function test_Claim() public {
        airdrop.claim(alice, ALICE_AMOUNT, _proofAlice());

        assertEq(token.balanceOf(alice), ALICE_AMOUNT);

        assertTrue(airdrop.hasClaimed(alice));
    }

    function test_ClaimFromOtherSideOfTree() public {
        airdrop.claim(carol, CAROL_AMOUNT, _proofCarol());

        assertEq(token.balanceOf(carol), CAROL_AMOUNT);
    }

    function test_ClaimEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit MerkleAirdrop.Claimed(alice, ALICE_AMOUNT);
        airdrop.claim(alice, ALICE_AMOUNT, _proofAlice());
    }

    function test_AnyoneCanClaimForSomeoneElse() public {
        vm.prank(bob);
        airdrop.claim(alice, ALICE_AMOUNT, _proofAlice());

        assertEq(token.balanceOf(alice), ALICE_AMOUNT);

        assertEq(token.balanceOf(bob), 0);
    }

    function test_RevertWhen_ClaimingTwice() public {
        airdrop.claim(alice, ALICE_AMOUNT, _proofAlice());

        vm.expectRevert(MerkleAirdrop.AlreadyClaimed.selector);
        airdrop.claim(alice, ALICE_AMOUNT, _proofAlice());
    }

    function test_RevertWhen_WrongAmount() public {
        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(alice, ALICE_AMOUNT * 2, _proofAlice());
    }

    function test_RevertWhen_NotOnTheList() public {
        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(mallory, ALICE_AMOUNT, _proofAlice());
    }

    function test_RevertWhen_EmptyProof() public {
        bytes32[] memory proof = new bytes32[](0);

        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(alice, ALICE_AMOUNT, proof);
    }
}
