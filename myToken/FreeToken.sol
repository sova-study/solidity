    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.18;

    import "./ERC20.sol";
    
    contract FreeToken is ERC20 {
        
        //подключаем в конструкторе конструктор из MyERC20, чтобы не дублировать код 
        constructor (address shop) ERC20("FreeToken", "FRT", 1000000, shop) {
        }
    }