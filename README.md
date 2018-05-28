# ERC948 Implementation

Recurring payments for Ethereum.

Based on the draft spec that's currently in development:
https://github.com/sb777/erc-948-draft/issues/1

Earlier discussions in the EIP issue:
https://github.com/ethereum/EIPs/issues/948#issuecomment-383886443

# Development

## Prerequisites

* Node.js v8.9.4
* Ganache (or some other local test ethereum node)
* Browser with MetaMask

## Installation

```
npm install
```

Deploy contract:

`truffle migrate`

## Run the webapp

```
cd app
npm install
npx webpack
npm start
```

Open in a browser:  http://localhost:8000

You can use the webapp to approve the subscription contract address to make transfers of GTC tokens on your behalf.
