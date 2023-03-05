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

        bytes memory signature = vm.sign(vm.envString("PK"), messageHash);
        console.logBytes(signature);
    }

    // function test_solveChallenge3() public returns (bytes32)

    // return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(t.length), t));
    // return keccak256(bytes('0x3cd65f6089844a3c6409b0acc491ca0071a5672c2ab2a071f197011e0fc66b6a'));
}
