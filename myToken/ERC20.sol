    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.18;

    //import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "./IERC20.sol";
   
    abstract contract ERC20 is IERC20 {
        uint totalTokens;
        address owner;
        mapping(address => uint) balances;// учет сколько токенов у конкретного адреса
        mapping(address => mapping(address =>uint)) allowances; //храним инфу о том,  с какого кошелька можно списать какое кол-во токенов.
        string _name;
        string _symbol;

        function name() external view returns(string memory) {
            return _name;
        }

        function symbol() external view returns(string memory) {
            return _symbol;
        }

        function decimals() external pure returns(uint) {
            return 18; // 1 токен = 1 wei
        }

        //проверяет, что на счету достаточно токенов для перевода
        modifier enoughTokens(address _from, uint _amount) {
            require(balanceOf(_from) >= _amount, "not enough tokens!");
            _;
        }

        // проверяет, что токены может перевести только владелец
        modifier onlyOwner(){
            require(msg.sender == owner, "not an owner!");
            _;
        }

        // При деплое устанавливает имя и символ нашего токена, кол-вл токенов, которое хочу изначально ввести в оборот, а также адрес магазина, где мы хотим эти токены продавать.
        constructor(string memory name_, string memory symbol_, uint initialSupply, address myShop) {
            _name = name_;
            _symbol = symbol_;
            owner = msg.sender;
            //функция, которая вводит токены в оборот
            mint(initialSupply, myShop);
        }

        function totalSupply() external view returns(uint) {
            return totalTokens;
        }

        function balanceOf(address account) public view returns(uint) {
            return balances[account];
        }
        
        // перевод с кошелька-инициатора транзакции на какой-то другой адрес токены. 
        function transfer(address to, uint amount) external  enoughTokens(msg.sender, amount) {
            _beforeTokenTransfer(msg.sender, to, amount);
            balances[msg.sender] -= amount; //списываем у себя токены
            balances[to] += amount; // добавляем на баланс получателя
            emit Transfer(msg.sender, to, amount); // вызываем событие о списании
        }

        function mint(uint amount, address myShop) public onlyOwner {
            _beforeTokenTransfer(address(0), myShop, amount);
            balances[myShop] += amount; // зачисляет токены на баланс магазина
            totalTokens += amount; //добавляет их к общему кол-ву
            emit Transfer(address(0), myShop, amount); // Вызывает событие с сообщением сколько выпущены токенов и зачислено на адрес магазина   
        }

        // дополнительная функция, выполняет проверку перед переводом токена (функция transfer)/ Служебная функция, поэтому internal
        function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}

        // Проверяет может ли сторонний аккаунт списать с вдадельца кошелька в пользу кого-то какую-то сумму
        function allowance(address _owner, address spender) public view returns(uint) {
            return allowances[_owner][spender];
        }

        // Кому разрешаем забирать токены и сколько
        function approve(address spender, uint amount) public {
            _approve(msg.sender, spender, amount);
        }

        //служебная функция, позволяет с адреса sender списать в пользу spender кол-во токенов amount. Необязательная функция. Используется только если нам явно нужно подтвердить у кого списываем, кому и сколько.
        function _approve(address sender, address spender, uint amount) internal virtual {
            allowances[sender][spender] = amount;
            emit Approval(sender, spender, amount);
        }
        // Забирает с указанного кошелька в пользу другого получателя кол-во токенов
        function transferFrom(address sender, address recipient, uint amount) public enoughTokens (sender, amount) {
            _beforeTokenTransfer(sender, recipient, amount); //проверяем, что на счету откуда списываем есть нужное кол-во токенов
        // require(allowances[sender][recipient] >= amount, "check allowance!"); // проверка, что разрешенная сумма больше, чем кол-во снимаемых токенов amount
            allowances[sender][recipient] -= amount; //вычтем то кол-во токенов, которое уже списали. Если sender не разрешил recipient у себя что-то списывать, тогда allowance вернет ноль.(дефолтное значение uint)
            balances[sender] -= amount; //забираем с баланса у sender кол-во снятых токенов
            balances[recipient] += amount; // добавляем получателю кол-во отправленных ему токенов
            emit Transfer(sender, recipient, amount);
        }

        //функция выводит токены из оборота
        function burn(address _from, uint amount) public onlyOwner {
            _beforeTokenTransfer(_from, address(0), amount);
            balances[_from] -= amount;
            totalTokens -= amount;
        }
    }