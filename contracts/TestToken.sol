pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract TestToken is StandardToken, Ownable {
  string public name = 'TestToken';
  string public symbol = 'TTT';
  uint8 public decimals = 18;
  uint public constant INITIAL_SUPPLY = 1000;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
