// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBank {
    function balances(address client) external view returns (uint256);
    function removeClient(address client) external;
    function bankName() external view returns (string memory);
}

contract Client {
    string public clientName;
    IERC20 public token;
    mapping(address => uint256) public bankBalances;
    address[] public banks;

    constructor(string memory _name, address _tokenAddress) {
        clientName = _name;
        token = IERC20(_tokenAddress);
    }

    function deposit(address bank, uint256 amount) external {
        require(amount > 0, "Kwota depozytu musi byc wieksza od zera.");
        require(bank != address(0), "Bledny adres banku");

        require(token.transferFrom(msg.sender, address(this), amount), "Transfer tokenow nie powiodl sie.");
        require(token.approve(bank, amount), "Zatwierdzenie tokenow nie powiodlo sie.");
        (bool success, ) = bank.call(
            abi.encodeWithSignature("deposit(uint256)", amount)
        );
        require(success, "Wplata nie powiodla sie.");

        if (bankBalances[bank] == 0) {
            banks.push(bank);
        }
        bankBalances[bank] += amount;
    }

    function withdraw(address bank, uint256 amount) external {
        require(amount > 0, "Kwota wyplaty musi byc wieksza od zera.");
        require(bank != address(0), "Bledny adres banku");

        (bool success, ) = bank.call(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        require(success, "Wyplata nie powiodla sie.");

        require(token.transfer(msg.sender, amount), "Transfer tokenow nie powiodl sie.");
        bankBalances[bank] -= amount;
        if (bankBalances[bank] == 0) {
            for (uint256 i = 0; i < banks.length; i++) {
                if (banks[i] == bank) {
                    banks[i] = banks[banks.length - 1];
                    banks.pop();
                    break;
                }
            }
        }
    }

    function removeFromBank(address bank) external {
        require(bank != address(0), "Bledny adres banku");

        IBank(bank).removeClient(address(this));
        if (bankBalances[bank] > 0) {
            bankBalances[bank] = 0;
        }

        for (uint256 i = 0; i < banks.length; i++) {
            if (banks[i] == bank) {
                banks[i] = banks[banks.length - 1];
                banks.pop();
                break;
            }
        }
    }

    function getBanks() external view returns (address[] memory) {
        return banks;
    }

    function getBankBalances() external view returns (string[] memory) {
        string[] memory result = new string[](banks.length);
        for (uint256 i = 0; i < banks.length; i++) {
            address bank = banks[i];
            uint256 balance = bankBalances[bank];
            string memory name = IBank(bank).bankName();
            result[i] = string(abi.encodePacked(
                "Bank: ", name,
                ", Address: ", toAsciiString(bank),
                ", Balance: ", uint2str(balance)
            ));
        }
        return result;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    receive() external payable {}
}

