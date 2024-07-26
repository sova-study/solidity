    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.18;
    
    import "./ERC20.sol";
    import "./FreeToken.sol";

    contract MyShop {
        
        IERC20 public token;//адрес, с которого мы будем продавать. Должен быть объектом, который реализует интерфейс IERC20. этот объект имеет все функции и события, указанные в интерфейсе
        address payable public owner;
        event Bought(uint _amount, address indexed _buyer);
        event Sold(uint _amount, address indexed _seller);

        constructor() {
            token = new FreeToken(address(this)); // операция развертывания стороннего смарт контракта. Передаем адрес того магазина, с которого будем реализовывать продажу токенов. нам достаточно развернуть контракт MyShop, который развернет FreeToken. Который в свою очередь делегирует в конструктор MyERC20.
            owner = payable(msg.sender); //делаем обычный адрес денежным
        } 
        
        modifier onlyOwner(){
            require(msg.sender == owner, "not an owner!");
            _;
        }
        // функция, с помощью которой наши клиенты будут покупать себе токены
        receive() external payable {
            uint tokensToBuy = msg.value; // 1 wei = 1 token
            require(tokensToBuy > 0, "not enough funds");

            require(tokenBalance() >= tokensToBuy, "not enough tokens!");
            // проверка на то, что у нас есть столько токенов, сколько у нас хотят купить.

            token.transfer(msg.sender, tokensToBuy); // стоит 2300 газа лимит
            emit Bought(tokensToBuy, msg.sender);
        }

        function sell(uint _amountToSell) external {
            
            require(_amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell, "incorrect amount!");
            
            // проверка что кол-во к продаже больше 0 и баланс отправителя должен быть больше или равен сумме, которую он хочет продать.

            //Так как смарт контракт магазина списывает с адреса msg.sender указанное кол-во токенов, нужно проверить разрешение. Было ли дано этому магазину разрешение на продажу.
            uint allowance = token.allowance(msg.sender, address(this));
            require(allowance >= _amountToSell, "check allowance!");
            
            token.transferFrom(msg.sender, address(this), _amountToSell);

            payable(msg.sender).transfer(_amountToSell);// компенсируем отпарвителю стоимость токенов, потому что он их продал

            emit Sold(_amountToSell, msg.sender);
        }
        
        // показывает сколько на счету в магазине есть токенов
        function tokenBalance() public view returns (uint) {
            return token.balanceOf(address(this));
        }
       
        // функция, которая позволит списать владельцу вырученные средства за продажу токенов
    }