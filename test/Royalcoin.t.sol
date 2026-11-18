// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Royalcoin} from "../src/Royalcoin.sol";

contract RoyalcoinTest is Test {
    Royalcoin token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new Royalcoin();
    }

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "Royalcoin");
        assertEq(token.symbol(), "XVII");
    }

    function test_DeployerGetsFullSupply() public view {
        assertEq(token.totalSupply(), 1000000000 ether);
        assertEq(token.balanceOf(address(this)), token.totalSupply());
    }

    function test_Transfer() public {
        token.transfer(alice, 100 ether);
        assertEq(token.balanceOf(alice), 100 ether);
    }

    function test_RevertWhen_NotEnoughBalance() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, 1 ether);
    }

    // --- Allowances ---
    
    function test_ApproveAndTransferFrom() public {
        token.approve(alice, 50 ether);
        assertEq(token.allowance(address(this), alice), 50 ether);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 30 ether);
        assertEq(token.balanceOf(bob), 30 ether);
        assertEq(token.allowance(address(this), alice), 20 ether);

    }

    function test_RevertWhen_TransferFromWithoutAllowance() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transferFrom(address(this), bob, 1 ether);
    }

    // --- Fuzz test ---

    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, token.totalSupply());
        uint256 before = token.balanceOf(address(this));
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(address(this)), before - amount);

    }

    // --- Supply never changes after transfers ---

    function testFuzz_SupplyUnchanged(uint256 amount) public {
        amount = bound(amount, 0, token.totalSupply());
        token.transfer(alice, amount);
        assertEq(token.totalSupply(), 1000000000 ether);
        
    }
}

