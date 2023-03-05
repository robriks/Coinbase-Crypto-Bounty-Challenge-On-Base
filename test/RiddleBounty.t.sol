// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RiddleBounty.sol";

contract BountyTest is Test {

    RiddleBounty public riddleBounty;

    uint256 baseFork;
    string BASE_RPC_ENDPOINT = vm.envString("BASE_RPC_ENDPOINT");
    
    function setup() public {
        baseFork = vm.createFork(BASE_RPC_ENDPOINT);
        vm.selectFork(baseFork);
    }

    function test_solveChallenge2() public {
        bytes memory riddleAnswer2 = bytes('The Merge');
        bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer2));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envUint("PK"), messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        console.logBytes(signature);
    }

    function test_solveChallenge3() public {
        bytes memory riddleAnswer3 = bytes('EIP-4844');
        bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer3));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envUint("PK"), messageHash);
        bytes memory vulnerableSig = abi.encodePacked(r, s, v);
        console.logBytes(vulnerableSig);
        bytes memory vulnerableSigReplay = abi.encodePacked(r, s);
        console.logBytes(vulnerableSigReplay);
    }
}
