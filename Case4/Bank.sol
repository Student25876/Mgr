// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Bank {
    string public bankName;
    IERC20 public token;
    mapping(address => uint256) public balances;
    address[] public clients;
    mapping(address => bool) public isClient;

    event Deposit(address indexed client, uint256 amount);
    event Withdrawal(address indexed client, uint256 amount);
    event ReturnFunds(address indexed client, uint256 amount);
    event RemovedClient(address indexed client, uint256 amountReturned);

    constructor(string memory _name, address _tokenAddress) {
        bankName = _name;
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Kwota depozytu musi byc wieksza od zera.");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer tokenow nie powiodl sie.");
        
        if (!isClient[msg.sender]) {
            clients.push(msg.sender);
            isClient[msg.sender] = true;
        }
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Kwota wyplaty musi byc wieksza od zera.");
        require(balances[msg.sender] >= amount, "Insufficient balance.");
        
        balances[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer tokenow nie powiodl sie.");
        emit Withdrawal(msg.sender, amount);
    }

    function returnFunds(address client, uint256 amount) external {
        require(client != address(0), "Bledny adres klienta");
        require(amount > 0, "Kwota zwrotu musi byc wieksza niz zero");
        require(balances[client] >= amount, "Wyplata jest wieksza niz depozyt klienta");

        balances[client] -= amount;
        require(token.transfer(client, amount), "Transfer tokenow nie powiodl sie.");
        emit ReturnFunds(client, amount);
    }

    function getTotalBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getClients() external view returns (address[] memory) {
        return clients;
    }

    function removeClient(address client) external {
        require(client != address(0), "Bledny adres klienta");
        require(isClient[client], "Adres nie jest klientem");
        
        uint256 balance = balances[client];
        if (balance > 0) {
            balances[client] = 0;
            require(token.transfer(client, balance), "Transfer tokenow nie powiodl sie.");
            emit ReturnFunds(client, balance);
        }

        isClient[client] = false;
        for (uint256 i = 0; i < clients.length; i++) {
            if (clients[i] == client) {
                clients[i] = clients[clients.length - 1];
                clients.pop();
                break;
            }
        }
        emit RemovedClient(client, balance);
    }
}
