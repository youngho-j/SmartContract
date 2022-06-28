pragma solidity ^0.4.4;


/*erc20 interface*/
contract Token {


    function totalSupply() public view returns (uint256 supply) {}


    function balanceOf(address _owner) public view returns (uint256 balance) {}


    function transfer(address _to, uint256 _value) public returns (bool success) {}


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}


    function approve(address _spender, uint256 _value) public returns (bool success) {}


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

// Token Contract를 상속 받음
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value); //(이벤트) 블록체인에 브로드캐스트하여 로그를 남김
            return true;
        } else { return false; }
    }


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }



    mapping (address => uint256) balances;


   uint256 public totalSupply;
}

contract TestToken is StandardToken { 

    string public name;                   // Token 이름
    uint8 public decimals;                // ETH의 wei,Gwei와 같이 해당 코인의 최소 단위를 설정
    string public symbol;                 // 토큰의 심볼 ex) TTN
    string public version = 'H1.0';       // 토큰 버전
    uint256 public Token_OneEthCanBuy;    // 1ETH로 살 수 있는 토큰 양
    uint256 public totalEthInWei;         // 토큰을 구매하면서 쌓이는 총 ETH 양(WEI 단위)
    address public fundManager;           // 토큰 최초 발행자

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    constructor () public {
        balances[msg.sender] = 1000000000000000000000;
        totalSupply = 1000000000000000000000;
        name = "TK";
        decimals = 18; // 해당 값이 18이므로 0이 18자리 이후 개수가 됨, 따라서 총 발행량은 1000개임
        symbol = "ABC"; 
        Token_OneEthCanBuy = 10;   
        fundManager = msg.sender;  
    }
    // 폴백 함수
    // 조건
    //  - 함수 이름이 없음(function signiture가 생성이 안됨)
    //  - external 필수
    //  - payable 필수
    // 사용 이유
    //   1. 어떤 상황이 발생했을때 캐치를 해 예외를 처리하기 위해서 *
    //   2. 스마트 컨트랙이 이더를 받을 수 있게 한다.
    //   3. 이더 받고 난 후 어떠한 행동을 취하게 할 수 있다. 
    //   4. call함수로 없는 함수가 불려질때, 어떠한 행동을 취하게 할 수 있다. *
    function() external payable{
        totalEthInWei += msg.value; 
        uint256 amount = msg.value * Token_OneEthCanBuy; //구매자가 사려하고 하는 토큰 양
        require(balances[fundManager] >= amount);

        balances[fundManager] -= amount; //토큰 발행자의 토큰 차감
        balances[msg.sender] += amount; //토큰 구매자에게 토큰 전달

        Transfer(fundManager, msg.sender, amount); // 블록체인에 브로드캐스트

        fundManager.transfer(msg.value);                               
    }
}