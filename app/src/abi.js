module.exports = [
  {
    "constant": true,
    "inputs": [
      {
        "name": "",
        "type": "bytes32"
      }
    ],
    "name": "subscriptions",
    "outputs": [
      {
        "name": "owner",
        "type": "address"
      },
      {
        "name": "payeeAddress",
        "type": "address"
      },
      {
        "name": "tokenAddress",
        "type": "address"
      },
      {
        "name": "amountRecurring",
        "type": "uint256"
      },
      {
        "name": "amountInitial",
        "type": "uint256"
      },
      {
        "name": "periodType",
        "type": "uint256"
      },
      {
        "name": "periodMultiplier",
        "type": "uint256"
      },
      {
        "name": "startTime",
        "type": "uint256"
      },
      {
        "name": "data",
        "type": "string"
      },
      {
        "name": "active",
        "type": "bool"
      },
      {
        "name": "nextPaymentTime",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "_subscriptionId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "name": "_payeeAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "_tokenAddress",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "_amountRecurring",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_amountInitial",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_periodType",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_periodMultiplier",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "_startTime",
        "type": "uint256"
      }
    ],
    "name": "NewSubscription",
    "type": "event"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_payeeAddress",
        "type": "address"
      },
      {
        "name": "_tokenAddress",
        "type": "address"
      },
      {
        "name": "_amountRecurring",
        "type": "uint256"
      },
      {
        "name": "_amountInitial",
        "type": "uint256"
      },
      {
        "name": "_periodType",
        "type": "uint256"
      },
      {
        "name": "_periodMultiplier",
        "type": "uint256"
      },
      {
        "name": "_startTime",
        "type": "uint256"
      },
      {
        "name": "_data",
        "type": "string"
      }
    ],
    "name": "createSubscription",
    "outputs": [
      {
        "name": "",
        "type": "bytes32"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "name": "_subscriptionId",
        "type": "bytes32"
      }
    ],
    "name": "paymentDue",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "name": "_subscriptionId",
        "type": "bytes32"
      },
      {
        "name": "_amount",
        "type": "uint256"
      }
    ],
    "name": "processSubscription",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
