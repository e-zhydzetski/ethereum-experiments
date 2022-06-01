// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MagicNum {

    address public solver;

    constructor() public {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
      ____________/\\\_______/\\\\\\\\\_____
       __________/\\\\\_____/\\\///////\\\___
        ________/\\\/\\\____\///______\//\\\__
         ______/\\\/\/\\\______________/\\\/___
          ____/\\\/__\/\\\___________/\\\//_____
           __/\\\\\\\\\\\\\\\\_____/\\\//________
            _\///////////\\\//____/\\\/___________
             ___________\/\\\_____/\\\\\\\\\\\\\\\_
              ___________\///_____\///////////////__
    */
}

abstract contract ISolver {
    function whatIsTheMeaningOfLife() virtual external pure returns (uint);
}

/*
// constructor
00 PUSH1 0a // size of runtime code for CODECOPY
02 DUP1     // duplicate size of runtime code for RETURN
03 PUSH1 0b // offset of runtime code (11 in dec)
05 PUSH1 00 // memory address for copy
07 CODECOPY // copy runtime code to memory
08 PUSH1 00 // memory address with runtime code
10 RETURN   // return runtime code from memory
// runtime
11 PUSH1 2a // result value 42 in hex
13 PUSH1 00 // memory address for value
15 MSTORE   // save result to memory (32 byte block)
16 PUSH1 20 // size of result (32 bytes)
18 PUSH1 00 // memory address with result
20 RETURN   // return result

// opcodes to bytecode with https://github.com/crytic/evm-opcodes
600a80600b6000396000f3602a60005260206000f3

// deploy from console
web3.eth.sendTransaction({from: player, data: "0x600a80600b6000396000f3602a60005260206000f3"})
*/