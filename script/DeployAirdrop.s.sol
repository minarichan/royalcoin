// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract DeployAirdrop is Script {
    IERC20 constant TOKEN = IERC20(0x1b61E824295E5593863DD6995a430fb5b1BDBD9e);
    uint256 constant TOTAL = 1750 * 10 ** 18;

    function run() external returns (MerkleAirdrop airdrop) {
        bytes32 root = vm.envBytes32("MERKLE_ROOT");

        vm.startBroadcast();
        airdrop = new MerkleAirdrop(TOKEN, root);
        bool ok = TOKEN.transfer(address(airdrop), TOTAL);
        require(ok, "funding failed");
        vm.stopBroadcast();

        console.log("MerkleAirdrop deployed at:", address(airdrop));
    }
}
