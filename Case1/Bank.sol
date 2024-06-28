// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Bank {
    mapping(address => uint256) public balances;
    event Withdrawal(address indexed client, uint256 amount);
    event ReturnFunds(address indexed client, uint256 amount);


    receive() external payable {
        require(msg.value > 0, "Kwota depozytu musi byc wieksza od zera.");
        balances[msg.sender] += msg.value;
    }


    function withdraw(uint256 amount) external {
        require(amount > 0, "Kwota wyplaty musi byc wieksza od zera.");
        require(balances[msg.sender] >= amount, "Insufficient balance.");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }


    function returnFunds(address client, uint256 amount) external {
        require(client != address(0), "Bledny adres klienta");
        require(amount > 0, "Kwota zwrotu musi byc wieksza niz zero");
        require(balances[client] >= amount, "Wyplata jest wieksza niz depozyt klietna");
        balances[client] -= amount;
        payable(client).transfer(amount);
        emit ReturnFunds(client, amount);
    }


    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
