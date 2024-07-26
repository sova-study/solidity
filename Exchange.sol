//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("Token A", "TKA") {
        _mint(msg.sender, 1000000); // Начальное распределение 1 000 000 токенов A
    }
}

contract TokenB is ERC20 {
    constructor() ERC20("Token B", "TKB") {
        _mint(msg.sender, 1000000); // Начальное распределение 1 000 000 токенов B
    }
}

contract TokenExchange  {
    address public tokenAAddress;
    address public tokenBAddress;

    constructor(address _tokenAAddress, address _tokenBAddress) {
        tokenAAddress = _tokenAAddress;
        tokenBAddress = _tokenBAddress;
    }

     // Получить баланс токенов A у пользователя
    uint256 userBalance = tokenA.balanceOf(msg.sender);
     
     
     
     
     // Функция для обмена токенов A на токены B
     function exchangeAToB(uint256 amount) public {
        TokenA tokenA = TokenA(tokenAAddress);
        TokenB tokenB = TokenB(tokenBAddress);   
     
        require(tokenA.balanceOf(msg.sender) >= amount, "Not enough tokens A");

        // Перевод токенов A с адреса пользователя на контракт
        tokenA.transferFrom(msg.sender, address(this), amount);
     }

// Функция для обмена токенов B на токены A
    function exchangeBToA(uint256 amount) public {
        TokenA tokenA = TokenA(tokenAAddress);
        TokenB tokenB = TokenB(tokenBAddress);

        require(tokenB.balanceOf(msg.sender) >= amount, "Not enough tokens B");

        // Перевод токенов B с адреса пользователя на контракт
        tokenB.transferFrom(msg.sender, address(this), amount);

        // Выдача токенов A пользователю
        tokenA.transfer(msg.sender, amount);
    }

    // Функция для покупки токенов A за ETH
    function buyAToken(uint256 amount) public payable {
        TokenA tokenA = TokenA(tokenAAddress);

        // Оплата токенов A в ETH
        require(msg.value >= amount, "Not enough ETH");

        // Выдача токенов A пользователю
        tokenA.transferFrom(msg.sender, address(this), amount);
    }

}




