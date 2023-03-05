# Coinbase Crypto Bounty Challenge
## Using Foundry to solve Coinbase's Mini-CTF on their brand new L2 EVM blockchain: Base

On March 3rd, during the week of EthDenver, the Twitter account for Coinbase's brand new layer 2 rollup forked from Optimism and settling on Ethereum, aptly named Base to complement their $COIN IPO, ![tweeted a surprise bounty challenge in the style of a ctf, entirely on-chain.](https://twitter.com/BuildOnBase/status/1631799257639313409?). I was cooking dinner with my spouse at the time but thankfully a great friend, silv.eth, alerted me to the challenge: thanks again, fren!

Incentives for the bounty include a $250 prize (in $ETH) for the first 50 solvers as well as a limited-edition NFT (and potential for a conversation with a Coinbase recruiter) for the first 500 to complete the challenge. Too good to pass up, so I put my glass of port down and got cracking at hacking it.

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

## The first challenge

The function that follows the first riddle looks like this: