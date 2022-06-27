pragma solidity ^0.5.8;

contract Lottery {
    address public manager; // 관리자 
    address payable[] private players; // 솔리디티 공식문서 규칙 보기

    constructor() public { // constructor : 배포시 자동으로 한번 실행되는 함수
        manager = msg.sender;
    }

    // 왜 단위를 ether, wei를 쓰는가?
    // ERC-20 특징
    // 대체 가능 / 소수점 단위로 계속 쪼갤 수 있다.
    // EVM은 연산시 소수점으로 연산시 메모리가 많이들게 됨
    // 그래서 데시멀을 통해서 소수점 단위를 정수로 변환하여 계산
    // 사용자에게 수수료를 절감해주기 위한 방법  

    function enter() public payable {
        require(msg.value >= .1 ether); 
        players.push(msg.sender);
    }

    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(now, msg.sender, players.length)));
    }

    function pickWinner() public restricted returns (address) {
        uint index = random() % players.length;

        address payable winner = players[index];

        winner.transfer(address(this).balance);
        
        players = new address payable[](0);

        return winner;
    }

    function getPlayers() public view returns(address payable[] memory) {
        return players;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    modifier restricted {
        require(msg.sender == manager);
        _;
    }
}