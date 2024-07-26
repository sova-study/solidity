
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; 

// Контракт токена A
contract TokenA is ERC20 {
    constructor() ERC20("Token A", "TCA") {
        _mint(msg.sender, 1000000); // Начальное распределение 1 000 000 токенов A
    }
}

// Контракт токена B
contract TokenB is ERC20 {
    constructor() ERC20("Token B", "TCB") {
        _mint(msg.sender, 1000000); // Начальное распределение 1 000 000 токенов B
    }
}

// Основной контракт обмена
contract TokenExchange {
    using SafeERC20 for IERC20;
    IERC20 public tokenA;
    IERC20 public tokenB;

    // Курс обмена
    uint256 public exchangeRate = 1;

    // Владелец контракта
    address payable public owner;

    // Стоимость одного токена A в ETH
    uint public rate = 1000*1e18; // tokens for 1 eth

    // Событие покупки токена A
    event BuyToken(address user, uint amount, uint costWei, uint balance);

    constructor(address _tokenAAddress, address _tokenBAddress) {
        tokenA = IERC20(_tokenAAddress); 
        tokenB = IERC20(_tokenBAddress); 
        owner = payable(msg.sender);
    }

    // Функция для получения баланса токенов A на контракте
    function tokenABalance() public view returns (uint256) {
        return tokenA.balanceOf(address(this));
    }

    // Функция для получения баланса токенов B на контракте
    function tokenBBalance() public view returns (uint256) {
        return tokenB.balanceOf(address(this));
    }

    // Функция для покупки токенов A за ETH
    function buyTokenA(uint amount) payable public returns (bool success) {
        // ensure enough tokens are owned by the depositor
        uint costWei = (amount * 1 ether) / rate;
        require(msg.value >= costWei);
        assert(tokenA.transfer(msg.sender, amount));
        emit BuyToken(msg.sender, amount, costWei, tokenA.balanceOf(msg.sender));
        uint change = msg.value - costWei;
        if (change >= 1) payable(msg.sender).transfer(change);
        return true;
    }
    
    // Функция для обмена токенов A на токены B
    function exchangeAToB(uint256 amount) public {
        require(tokenA.balanceOf(msg.sender) >= amount, "Not enough tokens A");

        tokenA.transferFrom(msg.sender, address(this), amount);
        tokenB.transfer(msg.sender, amount * exchangeRate);
    }

    // Функция для обмена токенов B на токены A
    function exchangeBToA(uint256 amount) public {
        require(tokenB.balanceOf(msg.sender) >= amount, "Not enough tokens B");

        tokenB.transferFrom(msg.sender, address(this), amount);
        tokenA.transfer(msg.sender, amount / exchangeRate);
    }
}
