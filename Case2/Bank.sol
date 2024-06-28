// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Bank {
    mapping(address => uint256) public repayments;
    mapping(address => uint256) public loanAmounts;


    event LoanApproved(address indexed client, uint256 amount);
    event LoanRepaid(address indexed client, uint256 amount);


    receive() external payable {}


    function approveLoan(address client, uint256 amount) external {
        require(amount > 0, "Kwota pozyczki musi byc wieksza od zera.");
        require(address(this).balance >= amount, "Niewystarczajace saldo banku.");
        loanAmounts[client] += amount;
        payable(client).transfer(amount);
        emit LoanApproved(client, amount);
    }


    function acceptRepayment(address client) external payable {
        require(msg.value > 0, "Kwota splaty musi byc wieksza od zera.");
        uint256 totalRepayment = loanAmounts[client] * 110 / 100;
        require(repayments[client] + msg.value <= totalRepayment, "Wartosc splaty jest zbyt duza.");
        repayments[client] += msg.value;
        emit LoanRepaid(client, msg.value);
    }


    function getRemainingDebt(address client) external view returns (string memory) {
        uint256 totalRepayment = loanAmounts[client] * 110 / 100;
        if (totalRepayment == 0) {
            return "Brak zaleglosci";
        }
        uint256 remainingDebt = totalRepayment > repayments[client] ? totalRepayment - repayments[client] : 0;
        if (remainingDebt == 0) {
            return "Brak zaleglosci";
        } else {
            return string(abi.encodePacked("Do splaty pozostalo: ", uint2str(remainingDebt), " wei"));
        }
    }


    function uint2str(uint256 _i) internal pure returns (string memory) {
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
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}


