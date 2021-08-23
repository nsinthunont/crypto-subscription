# Crypto Subscription

## Introduction
This repo contains a template smart contract which can be used to offer customers subscription plans which are billed over a provided duration. Subscription business models in the Web2 world are highly attractive because of the recurring nature of future revenue streams. Examples of some companies are:
* Spotify
* Netflix
* Apple
* Disney
* Amazon
* Instacart
* Barkbox
* etc...

On-chain subscription contracts will help to open new funding avenues for dApps and lead the way for a new branch of B2B DeFi which is similar to Pipe (https://pipe.com/) where long duration recurring revenue contracts can be redeemed for cash today in order to make immediate investments.

## Setup dependencies
To install all the dependencies in a all project:
```
npm install --save ethers hardhat @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers web3modal @openzeppelin/contracts 
```
We will also want to install some dev dependencies for testing purposes
```
npm install --save-dev @openzeppelin/test-helpers @nomiclabs/hardhat-web3 web3
```
Don't forget to modify the hardhat.config.js file by adding the following to the top or else the test-helpers will not function properly
```
require("@nomiclabs/hardhat-web3");
```

## Usage
To test the smart contracts using the provide test file:
```
npx hardhat test
```

## Future
There are several upgrades that are available to the current template including:
* Reward users who trigger the make payment function on behalf of the merchant
* Subscription models where the funds are streaming each second from the customer to the merchant's wallet

