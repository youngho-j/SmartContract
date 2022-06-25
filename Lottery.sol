pragma solidity ^0.5.8;

contract Lottery {
    address public manager;
    address payable[] public players;

    constructor() public {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > .01 ether); // 이더 값이 0.1 이상? >= 인지 >
        players.push(msg.sender);
    }

    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(now, msg.sender, players.length)));
    }

    function pickWinner() public restricted returns (address) {
        uint index = random() % players.length;

        address payable winner = players[index];

        winner.transfer(address(this).balance);
        
        players = new address payable[](0); // show_players 어디서 온 변수? 

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