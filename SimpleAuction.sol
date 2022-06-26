pragma solidity ^0.5.8;

contract SimpleAuction {

    address payable public beneficiary;

    uint public auctionClosingTime;

    address public highestBidder;

    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended; 

    event HighestBidIncreased(address bidder, uint amount);

    event AuctionEnded(address winner, uint amount);

    constructor (uint _biffingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        auctionClosingTime = now + _biffingTime;
    }

    function bid() public payable {
        require(now <= auctionClosingTime);
        
        require(msg.value > highestBid);

        if(highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }


    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];

        if(amount > 0) {
            if(!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(now >= auctionClosingTime);

        require(!ended);

        ended = true;
        
        emit AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer(highestBid);
    }
}

// 궁금한 점
// event 작동 원리