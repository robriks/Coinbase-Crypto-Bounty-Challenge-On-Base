// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RiddleBounty.sol";

contract BountyTest is Test {

    RiddleBounty public riddleBounty;

    uint256 privKey;
    address hacker;

    uint256 baseFork;
    string BASE_RPC_ENDPOINT = vm.envString("BASE_RPC_ENDPOINT");
    
    function setUp() public {
        baseFork = vm.createFork(BASE_RPC_ENDPOINT);
        vm.selectFork(baseFork);
        riddleBounty = RiddleBounty(0xc1e40f9FD2bc36150e2711e92138381982988791); // bounty address on Base chain
        privKey = vm.envUint("PK");
        hacker = vm.addr(privKey);
    }

    function test_solveChallenge1() public {
        vm.prank(hacker);
        riddleBounty.solveChallenge1('faucet');

        assertTrue(riddleBounty.hasSolvedChallenge1(hacker));
    }

    function test_solveChallenge2() public {
        test_solveChallenge1(); // challenges must be solved sequentially

        bytes memory riddleAnswer2 = bytes('The Merge');
        bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer2));
        bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, signedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        console.logBytes(signature);

        vm.prank(hacker);
        riddleBounty.solveChallenge2('The Merge', signature);
        
        assertTrue(riddleBounty.hasSolvedChallenge2(hacker));
    }

    function test_solveChallenge3() public {
        test_solveChallenge1();
        test_solveChallenge2(); // solve other challenges preceding the third

        bytes memory riddleAnswer3 = bytes('EIP-4844');
        bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer3));
        bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, signedMessageHash);
        bytes memory vulnerableSig = abi.encodePacked(r, s, v);
        console.logBytes(vulnerableSig);
        bytes memory vulnerableSigReplay = abi.encodePacked(r, s);
        console.logBytes(vulnerableSigReplay);

        vm.startPrank(hacker);
        riddleBounty.solveChallenge3('EIP-4844', hacker, vulnerableSig);
        riddleBounty.solveChallenge3('EIP-4844', hacker, vulnerableSigReplay);
        vm.stopPrank();

        assertTrue(riddleBounty.isOnLeaderboard(hacker));
    }
}
