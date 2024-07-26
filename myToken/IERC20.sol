// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


interface  IERC20 {
    // Возвращает имя токена
    function name() external view returns(string memory);

    // Возвращает символ токена
    function symbol() external view returns(string memory);

   // Устанавливает кол-во знаков после запятой
    function decimals() external view returns(uint);

    // Возвращает общее кол-во произведенных токенов, сколько есть в обороте
    function totalSupply() external view returns(uint);

    // Возвращает кол-во токенов на конкретном адресе
    function balanceOf(address account) external view returns(uint);

   // переводит указанное кол-во токенов на указанный адрес
   function transfer(address to, uint amount) external;  
    
    // Нужно для того, чтобы мы, владельцы кошелька могли позволить другому адресу забрать определенное кол-во токенов в пользу третьего лица.Напр: сторонний смарт-контракт Магазин списывает с нашего адреса токены, которые мы хотим продать, на другой кошелек.
    function allowance(address _owner, address spender) external view returns(uint);

    // Подтверждает перевод токенов с нашего кошелька на другой адрес/ Здесь мы устанавливаем кто у нас может списывать токены и в каком кол-ве.
    function approve(address spender, uint amount) external;

    // Непостредственно списывает  с нашего аккаунта опред кол-во токенов
    function transferFrom(address sender, address recipient, uint amount) external;

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed to, uint amount);
 
}