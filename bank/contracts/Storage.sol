// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <1.0.0;

contract Storage {
  mapping (string => uint256) _uintStorage;
  mapping (string => address) _addressStorage;
  mapping (string => bool) _boolStorage;
  mapping (string => string) _stringStorage;
  mapping (string => bytes4) _bytesStorage;

  mapping(address=>timeLock[]) public locking;
  mapping(address => uint256) public balances;
  
  struct timeLock{
    uint256 amount;
    uint256 timerStart;
    uint256 timerEnd;
    uint256 timeFirstWithdraw;
    uint256 timeForWithdraw;
    uint256 lastWithdraw;
    address reserveAccount;
    bool reserveActive;
  }
  address public owner;
  bool public _initialized;
}

//altWithdraw
// test -->timetravel? and other
    //function allowance + use amount and not msg.value
