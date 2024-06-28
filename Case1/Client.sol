// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Client {
   
    address payable public bank;


    constructor(address payable _bank) {
        bank = _bank;
    }


    function deposit(uint256 amount) external payable {
        require(amount > 0, "Kwota depozytu musi byc wieksza od zera.");
        (bool success, ) = bank.call{value: amount}("");
        require(success, "Wplata nie powiodla sie.");
    }


    function withdraw(uint256 amount) external {
        require(amount > 0, "Kwota wyplaty musi byc wieksza od zera.");
        (bool success, ) = bank.call(
            abi.encodeWithSignature("withdraw(uint256)", amount)
        );
        require(success, "Wplata nie powiodla sie");
    }




    receive() external payable {}
}








// client.sol:


// Funkcja deposit umożliwia wpłatę środków do banku.
// Funkcja withdraw umożliwia wypłatę środków z banku przez klienta.
// Funkcja requestRefund wywołuje funkcję returnFunds w kontrakcie banku, aby zażądać zwrotu środków na adres klienta.




// Bank.sol:


// Funkcja receive umożliwia bankowi odbieranie wpłat i zapisywanie sald klientów.
// Funkcja withdraw umożliwia klientom wypłatę środków z banku.
// Funkcja returnFunds umożliwia bankowi zwrot środków na adres klienta.
// Funkcja getTotalBalance zwraca całkowite saldo banku.
