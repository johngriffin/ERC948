// Expects web3 to be v.0.2

import $ from 'jquery';
var Web3 = require('web3')

let token_address = undefined
let network_id = undefined

token_address = '0x25ad2fb0d6ab1122633ccde2b430dfd381cff650';  //ropsten
network_id = 3 // ropsten - ethereum network ID

const abi = require('./abi.js');


// Check for Metamask and show/hide appropriate warnings.
window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if ((typeof web3 !== 'undefined') && (web3.givenProvider !== null)) {
    var web3js = new Web3(web3.currentProvider);

    // Checking if user is logged into an account
    web3js.eth.getAccounts(function(err, accounts){
        if (err != null) console.error("An error occurred: "+err);

        // User is not logged into Metamask
        else if (accounts.length == 0) {
          $('#metamask-login').show();
          console.log("User is not logged in to MetaMask");
        }

        // User is logged in to Metamask
        else {
          web3js.version.getNetwork((err, net_id) => {
            console.log(net_id);
            if (err != null) console.error("An error occurred: "+err);

            // User is on the correct network
            // Ropsten test network = 3, main net = 1
            else if (net_id == network_id) {
              console.log("User is logged in and on correct network");
              $('#main-content').show();

              startApp(web3js);
            }

            // User is not on the right network
            else {
              console.log("User is logged in and on WRONG network");
              $('#metamask-network').show();
            }
        })
      }
  });

  // User does not have Metamask / web3 provider
  } else {
    console.log('No web3? You should consider trying MetaMask!');
    $('#metamask-install').show();
  }
})


function startApp(web3js) {
  var tokenContract = web3js.eth.contract(abi).at(token_address);

  web3.eth.getTransactionReceiptMined = function getTransactionReceiptMined(txHash, interval) {
      const self = this;
      const transactionReceiptAsync = function(resolve, reject) {
          self.getTransactionReceipt(txHash, (error, receipt) => {
              if (error) {
                  reject(error);
              } else if (receipt == null) {
                  setTimeout(
                      () => transactionReceiptAsync(resolve, reject),
                      interval ? interval : 500);
              } else {
                  resolve(receipt);
              }
          });
      };

      if (Array.isArray(txHash)) {
          return Promise.all(txHash.map(
              oneTxHash => self.getTransactionReceiptMined(oneTxHash, interval)));
      } else if (typeof txHash === "string") {
          return new Promise(transactionReceiptAsync);
      } else {
          throw new Error("Invalid Type: " + txHash);
      }
  };

  let getBalance = function(account) {
    return new Promise(function(resolve, reject) {
      tokenContract.balanceOf(account,
        function (err, res) {
          if (err) {
            console.error(err);
            reject(err);
          }
          else {
            resolve(res.c[0]);
          }
      });
    })
  }

  let updateMyBalance = function() {
    getBalance(web3js.eth.accounts[0]).then(function(balance) {
      console.log('in updateMyBalance = ' + balance)
      $('#token_count').text(balance);
    });
  }

  $('.approve').on('click', function () {
    let address = $('.approve_address').val();
    console.log(address);

    tokenContract.approve(
      address,
      1000000,
    {
      'from':web3js.eth.accounts[0]
    },
    function (err, transactionHash) {
        console.log(err, transactionHash);
        return web3.eth.getTransactionReceiptMined(transactionHash, 5000).then(function (receipt) {
          console.log('approve transaction complete: ');
          console.log(receipt)
        });
    });
  });

  updateMyBalance();
  $('#eth_address').text(web3js.eth.accounts[0]);
}
