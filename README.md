# Coinbase Crypto Bounty Challenge
## Using Foundry to solve Coinbase's Mini-CTF on their brand new L2 EVM blockchain: Base

On March 3rd, during the week of EthDenver, the Twitter account for Coinbase's brand new layer 2 rollup forked from Optimism and settling on Ethereum, aptly named Base to complement their $COIN IPO, ![tweeted a surprise bounty challenge in the style of a ctf, entirely on-chain.](https://twitter.com/BuildOnBase/status/1631799257639313409?). I was cooking dinner with my spouse at the time but thankfully a great friend, silv.eth, alerted me to the challenge: thanks again, fren!

Incentives for the bounty include a $250 prize (in $ETH) for the first 50 solvers as well as a limited-edition NFT (and potential for a conversation with a Coinbase recruiter) for the first 500 to complete the challenge. Too good to pass up, so I put my glass of port down and got cracking at hacking it.

##### You'll find the challenge itself, RiddleBounty.sol, in the ./src directory and the solutions to the challenges in the RiddleBounty.t.sol file in the ./test directory. The solutions can be run as Foundry tests via ```forge test```

## The Contract

Following the link in the tweet from ![@buildonbase](https://twitter.com/buildonbase) takes you to a signup page to register for the contest, download Coinbase Wallet, connect it to your Coinbase exchange account, and finally direct you to ![the contract address of the bounty](https://goerli.basescan.org/address/0xc1e40f9FD2bc36150e2711e92138381982988791). 

###### I actually solved the challenge before registering for the contest, oops. Hopefully that doesn't count against me.

First thing you'll note is that we're on a Goerli testnet version of the Base blockchain, so we need not worry about putting any real funds at stake. Great!

BaseScan provides a pretty awesome spin on the industry standard Etherscan, so kudos to CoinBase for setting that up nice and pretty.

## The contract address's code

Navigating to the smart contract's source code, we can see five Solidity files: four of which run-of-the-mill dependency imports for Ownership, Context, String operation, and Elliptical Curve Digital Signature Algorithm functionality. Each import utilizes the most common open-source codebase for its purpose, provided by ![OpenZeppelin](https://openzeppelin.com), a web3 powerhouse of Solidity resources.

###### If you enjoyed this Coinbase mini-CTF, check out ![Openzeppelin's Ethernaut challenge, a similarly structured on-chain CTF](https://ethernaut.openzeppelin.com).

The fifth Solidity file, RiddleBounty.sol, is of most interest to us- you can find the source code for that contract in its entirety within the ./src directory of this repo. Fret not, I'll include relevant code snippets of the file as we discuss the exploits at play.

## The riddles

A quick cursory look over the contract code will expose a few things, the most evident of which is an unusual pattern of four line comments that do not adhere to the usual Solidity NatSpec guidelines.

A closer look will identify these as riddles! Hackers love puzzles- using riddles as part of the challenge reminds me a lot of challenges you'd find at ![DefCon](https://defcon.org). Sublime!

Here are the riddles:

Lines 73-76
```solidity
/// In the new world there's a curious thing,
/// A tap that pours coins, like a magical spring
/// A free-for-all place so vast,
/// A resource that fills your wallet fast (cccccc)
```

Lines 83-86
```solidity
/// Onward we journey, through sun and rain
/// A path we follow, with hope not in vain
/// Guided by the Beacon Chain, with unwavering aim
/// Our destination approaches, where two become the same (Ccc Ccccc)
```

Lines 105-108
```solidity
/// A proposal was formed, a new blob in the land,
/// To help with the scale, and make things more grand
/// A way to improve the network's high fees,
/// And make transactions faster, with greater ease (CCC-NNNN)
```

## The twist

Each riddle precedes an externally visible smart contract function that accepts one or more parameters, for hackers like you to provide your chosen solution. For the first function, named 

```solveChallenge1(string calldata riddleAnswer)```

the riddle answer string is all that's needed, though you'll soon find that's not the case for the later challenges. Just solving riddles would be far too easy, so there's some good cryptography work to be had in the following challenges.

Another small anomaly to note is the C/c and N characters within parentheses that follow the end of each riddle. Looks possibly like a way to denote the formatting and capitalization of the riddle answers.

Onto the first challenge, then.

## The first challenge

The function that follows the first riddle looks like this:

```solidity
function solveChallenge1(string calldata riddleAnswer) isOpen() external {
    if (RIDDLE_1_HASH == keccak256(abi.encodePacked(riddleAnswer))) {
        solvedChallenge1[msg.sender] = true;
    }
}
```

Pretty straightforward, just call the function while providing the answer to the riddle as the calldata string parameter ```riddleAnswer```. If the string keccak256 hashes match, we successfully flip a boolean.

Have you solved the riddle yet? It's a bit of a freebie, seeing as you've definitely used one of these in the process of onboarding your Coinbase Wallet to the Base optimistic chain!

That's right, the riddle is referring to the testnet faucet that you used to obtain some Base Goerli $ETH!

### Wrangling the contract on-chain

To interact with the chain, I used Foundry since that and Hardhat are my bread and butter, though you could opt for Truffle or even Etherscan if that's more your style. 

First I set some environment variables so that we can reuse them in each call to solve the three challenges:

```bash
export BOUNTY_ADDR=0xc1e40f9FD2bc36150e2711e92138381982988791
export BASE_RPC_ENDPOINT=https://base-goerli.infura.io/v3/$YOUR_INFURA_API_KEY
export PK=$YOUR_HEX_PREFIXED_PRIVATE_KEY
export HACKER=$YOUR_ADDRESS_FROM_PRIVATE_KEY
```

With those set, here's the Foundry command I used to write to the RiddleBounty contract on-chain:

```bash
cast send $BOUNTY_ADDR --private-key $PK --rpc-url $BASE_RPC_ENDPOINT "solveChallenge1(string)" faucet
```

If all went well, the transaction receipt is printed to the terminal and we can make a quick call to the view function on line 53 to ensure the boolean has been flipped in the mapping for our address:

```solidity
function hasSolvedChallenge1(address user) external view returns (bool) {
    return solvedChallenge1[user];
}
```

To do so, use Foundry's cast call functionality:

```bash
cast call $BOUNTY_ADDR --rpc-url $BASE_RPC_ENDPOINT "hasSolvedChallenge1(address)(bool)" $HACKER
```

A hex-encoded value for 1 returned by the contract means we have indeed solved challenge 1!

## The second challenge

Moving on, the function that follows the second riddle is shown below:

```solidity
function solveChallenge2(string calldata riddleAnswer, bytes calldata signature) isOpen() external {
    bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer));

    require(RIDDLE_2_HASH == messageHash, "riddle not solved yet");

    require(
        msg.sender == ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), signature),
        "invalid signature"
    );

    if (solvedChallenge1[msg.sender]) {
        solvedChallenge2[msg.sender] = true;
    }
}
```

Just a hair trickier, as now we'll need to provide two parameters to this function to solve the challenge at hand: a calldata bytes ```signature``` in addition to the calldata string ```riddleAnswer``` as we did before.

In the first four lines of the function, we see similar logic to the first challenge- checking the keccak256 hash of ```riddleAnswer``` against the correct one from storage named ```RIDDLE_2_HASH```

The next 4 lines of the function however invoke the OpenZeppelin ECDSA library to validate the calldata bytes ```signature``` we must provide. By examining the inputs to the 

```ECDSA.recover()```

function, we can surmise that the bytes32 ```messageHash``` is the input to be signed by our private key in order to craft a message hash that can be recovered to our public address ($HACKER).

So, let's generate the signature that the contract needs to continue execution and flip the ```solvedChallenge2[]``` mapping's boolean for our $HACKER address.

### Generating the ECDSA signature using Foundry

##### Quick aside before moving on, all this can of course be done easily using Hardhat or Truffle with the common Ethersjs library, I just happen to prefer working on-chain with Foundry.

To generate our signature, we can write a Solidity contract that makes use of Foundry's nifty vm cheatcodes. There's a handy dandy sign method on the vm object, which we can invoke as follows:

```solidity
function test_solveChallenge2() public {
    bytes memory riddleAnswer2 = bytes('The Merge');
    bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer2));

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envUint("PK"), messageHash);
    bytes memory signature = abi.encodePacked(r, s, v);
    console.logBytes(signature);
}
```

A few things to note: we've provided the ```riddleAnswer2``` as a hardcoded string typecast to bytes.in memory and then hashed it to obtain the bytes32 ```messageHash``` used in Coinbase's RiddleBounty contract.

Next we use Foundry's ```vm.sign``` functionality, providing our private key as an environment variable and the messageHash to be signed. This returns the signature we're interested in, but with the recovery key (denoted above as ```uint8 v```) appearing first. Since ECDSA signatures usually concatenate the recovery key at the end of a signature, we use ```abi.encodePacked``` to concatenate the values in the standard order: r + s + v.

Last, we log the signature to the console for you to grab and set as another environment variable to be provided as the second parameter to solve the second challenge!

### Do the thing

All that's left to do is submit our hack transaction to the chain!

```bash
export SIG=$YOUR_CONSOLE_LOGGED_SIGNATURE
cast send $BOUNTY_ADDR --private-key $PK --rpc-url $BASE_RPC_ENDPOINT "solveChallenge2(string,bytes)" 'The Merge' $SIG
```

Boom. Yet again, we can have a look at the view function to see if we passed the second challenge:

```bash
cast call $BOUNTY_ADDR --rpc-url $BASE_RPC_ENDPOINT "hasSolvedChallenge2(address)(bool)" $HACKER
```

Great! It seems we were correct in assuming the (Ccc Cccc) at the end of the second riddle specifies which characters of the riddleAnswer should be capitalized.

## The third and final challenge

Did you notice anything about challenge 2, hacker anon? That's right, there was a signature malleability vulnerability that allowed for a signature replay attack! Looking over challenge 3, we can see that is yet again the case and now the challenge explicitly calls for us to exploit this vulnerability:

```
function solveChallenge3(
    string calldata riddleAnswer,
    address signer,
    bytes calldata signature
) isOpen() external {
    require(signer != address(0), "signer cannot be zero address");

    bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer));
    require(RIDDLE_3_HASH == messageHash, "riddle answer incorrect");

    require(
        signer == ECDSA.recover(RIDDLE_3_ETH_MESSAGE_HASH, signature),
        "invalid signature, message must be signed by signer"
    );

    if (previousSignature[signer].length == 0) {
        previousSignature[signer] = signature;
        userWhoUsedSigner[signer] = msg.sender;
        return;
    }

    require(userWhoUsedSigner[signer] == msg.sender, "solution was used by someone else");

    require(
        keccak256(abi.encodePacked(previousSignature[signer])) != keccak256(abi.encodePacked(signature)),
        "you have already used this signature, try submitting a different one"
    );

    if (solvedChallenge2[msg.sender] && (finishingTimes[msg.sender] == 0)) {
        finishingTimes[msg.sender] = block.timestamp;
        leaderboard.push(msg.sender);
    }
}
```

As shown by the ```v, r, s``` variables we coded to solve the last challenge, ECDSA signatures comprise three parts: two bytes32 variables concatenated with a uint8 recovery ID to form a 65 byte signature that can be deconstructed to obtain the signer's public address. Less well-known, however, is that the uint8 recovery ID ```v``` is used for other purposes than verifying the signer and so it can be omitted while validating the signature.

This means that attackers can carry out replay attacks by lopping off the final byte (since uint8 is a single byte) of a valid signature and reuse them to trick a system into accepting the same signature twice.

First let's generate the signature to replay, using the riddle's strongly hinted blobspace EIP as our ```riddleAnswer```. We know the EIP letters must be capitalized, followed by a hyphen and the number 4844 from the (CCC-NNNN) hint given at the end of the third riddle.

```solidity
function test_solveChallenge3() public {
    bytes memory riddleAnswer3 = bytes('EIP-4844');
    bytes32 messageHash = keccak256(abi.encodePacked(riddleAnswer3));

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(vm.envUint("PK"), messageHash);
    bytes memory vulnerableSig = abi.encodePacked(r, s, v);
    console.logBytes(vulnerableSig);
    bytes memory vulnerableSigReplay = abi.encodePacked(r, s);
    console.logBytes(vulnerableSigReplay);
}
```

Keep in mind this is only a vulnerability when the ```v, r, s``` variables are lumped together into a bytes array OR when signature lengths are not restricted to either 64 or 65 bytes. Since neither is the case here, we can carry out the replay attack in two calls using the riddle answer, our signer address, and each of the two signatures we've logged to the console (```vulnerableSig``` and ```vulnerableSigReplay```)

```bash
export VULNSIG=$YOUR_CONSOLE_LOGGED_VULNERABLESIG
export VULNSIGREPLAY=$YOUR_CONSOLE_LOGGED_VULNERABLESIGREPLAY

cast send $BOUNTY_ADDR --private-key $PK --rpc-url $BASE_RPC_ENDPOINT "solveChallenge3(string,address,bytes)" EIP-4844 $HACKER $VULNSIG

cast send $BOUNTY_ADDR --private-key $PK --rpc-url $BASE_RPC_ENDPOINT "solveChallenge3(string,address,bytes)" EIP-4844 $HACKER $VULNSIGREPLAY
```

The first call into this function using the 65 byte signature will initialize values in two storage mappings in lines 128-129 before returning:

```solidity
previousSignature[signer] = signature;
userWhoUsedSigner[signer] = msg.sender;
return
```

The second time we call into this function with the 64 byte replayed signature, execution skips over that code in the if block, checks we did successfully set those storage mappings properly, compares the new signature to the previously used one to ensure they are different, and then pushes our address to the leaderboard and saves our challenge completion time using ```block.timestamp```!

We've successfully hacked Coinbase's mini-CTF and made the leaderboard for this challenge! Congratulations.

## PWNT

○•○ h00t h00t ○•○
-KweenBirb / Robriks / 👦🏻👦🏻.eth