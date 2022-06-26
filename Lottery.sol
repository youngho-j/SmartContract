pragma solidity ^0.5.8;

contract Lottery {
    address public manager;
    address payable[] public players;

    constructor() public {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > .01 ether);
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

    modifier restricted {
        require(msg.sender == manager);
        _;
    }
}

// 궁금한점
// enter 메서드 중 0.1 ether로 입력시 에러.. 
// random 메서드 중 encodePacked : 비포장 형식이 뭔지
// show_players는 어디에 사용되는건지.. 일단 참여자들을 보여주는 것 같아 고침
// 배열에 payable modifier 붙일 경우 꼭 [] 앞에 선언하기