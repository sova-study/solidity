// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PPracticum {
    // Создать переменные (uint, address, bool)
    uint public myUint;
    address public owner;
    bool public myBool;

    // Создать константу и immutable
    string constant public MYCONSTANT = "Hello, Vlad!";
    uint  immutable public MYIMMUTE;

    // Создать маппинг
    mapping(address => uint) public balances;

    // Создать массив с динамической длиной
    uint[] public dinamicArray;

    // Создать 2 модификатора: на проверку владельца и проверку нулевого адреса
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an Owner!");
        _;
    }

    modifier zeroAddr(address _addr) {
        require(_addr != address(0), "Not valid address!");
        _;
    }
    
    // Создать вложенный мэппинг (nested mapping);
    mapping(address => mapping(uint => uint)) public nestedMapping;

    // Создать мэппинг со структурой;
      struct Person {
        uint age;
        string name;
    }
    mapping(address => Person) public persons;

    // Создать структуру, в которой будет другая структура;
    struct Car {
        string model;
        uint year;
        string colour;
    }
    struct CarOwner {
        string name;
        Car car;
    } 

    // Создать массив структур.
     Car[3] carsArray;


    // Написать функции:
    // 1. Изменение адреса владельца контракта с проверкой на нулевой адрес;
    function changeAddress(address _newAddress) public zeroAddr(_newAddress) {
       // require(_newAddress != address(0), "Not valid address!");
        owner = _newAddress;
    }
    // 2. Которая будет устанавливать immutable в конструкторе;
    constructor(uint _value) {
        MYIMMUTE = _value;
    }

    // 3. Которая будет добавлять значение в динамический массив;
    function addToDinamicArray(uint _one, uint _two, uint _three) public {
        dinamicArray.push(_one);  
        dinamicArray.push(_two); 
        dinamicArray.push(_three); 
    }
    // 4. Которая будет удалять значение из массива с уменьшением его длины;
    function delFromArray() public {
        dinamicArray.pop();
    }
    // 5. Которая будет добавлять значение во вложенном мэппинге;
    function addToNestedMapping(uint key1, uint value) public {    //  mapping(address => mapping(uint => uint)) public nestedMapping;
        nestedMapping[msg.sender][key1] = value;
    }
    // 6. Которая будет удалять значение во вложенном мэппинге;
    function delFromNestedMapping(uint value) public {    //  mapping(address => mapping(uint => uint)) public nestedMapping;
        nestedMapping[msg.sender][value] = 0;
    }
    // 7. Которая будет добавлять значения struct в мэппинге;
    function addToStructMapping(address _address, uint _age, string memory _name) public {   // mapping(address => Person) public persons;
        persons[_address] = Person(_age, _name);
    }
    
    // 8. Которая будет добавлять значение в массив структур;   Car[] carsArray;
    function addToStructArray(string memory _model, uint _year, string memory _colour) public {
         uint256 index = carsArray.length;
         carsArray[index] = Car(_model, _year, _colour);
    }
    // 9. Которая будет добавлять в простой маппинг запись, что пользователю пришел эфир.
    function addBalance(address _address, uint256 _amount) public payable {
      _amount = msg.value;
        balances[_address] += msg.value; // Добавление _amount к балансу _address
    }
}

