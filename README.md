# Royalcoin (XVII)

![CI}](https://github.com/minarichan/royalcoin/actions/workflows/test.yml/badge.svg)

A fixed-supply ERC-20 token built with Foundry and OpenZeppelin.

## Overview 
- **Name / symbol:** Royalcoin / XVII
- **Supply:** 1,000,000,000 XVII, minted once to the deployer
- **Decimals:** 18

# Design decisions
- **Fixed supply:** there is not mint function, so the supply can never grow.
- **No admin keys:** there is no owner, pause or blacklist, no one can freexe or seize tokens.
- **OpenZeppelin ERC-20:** built on audited, widely used code instead of custom token logic.

## Getting started 
```bash

git clone --recursive https://github.com/minarichan/royalcoin.git

cd royalcoin

forge build

forge test -vv

```

## Tests
Tests cover metadata, initial supply, transfers and failed transfers on insufficient balance.

## Deployment 
Sepolia: [0x1b61E824295E5593863DD6995a430fb5b1BDBD9e](https://sepolia.etherscan.io/address/0x1b61E824295E5593863DD6995a430fb5b1BDBD9e)

## License
MIT