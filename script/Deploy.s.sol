// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Royalcoin} from "../src/Royalcoin.sol";

contract Deploy is Script {
    function run() external returns (Royalcoin token) {
        vm.startBroadcast();
        token = new Royalcoin();
        vm.stopBroadcast();
        console.log("Royalcoin deployed at:", address(token));
    }
}
