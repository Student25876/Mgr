// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyContract {
    IERC20 public magisterCoin;

    constructor(address _tokenAddress) {
        magisterCoin = IERC20(_tokenAddress);
    }

    function getBalance(address account) external view returns (uint256) {
        return magisterCoin.balanceOf(account);
    }

    function transfer(address to, uint256 amount) external {
        require(magisterCoin.transferFrom(msg.sender, to, amount), "Transfer failed");
    }

    function approve(address spender, uint256 amount) external {
        require(magisterCoin.approve(spender, amount), "Approval failed");
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return magisterCoin.allowance(owner, spender);
    }
}

