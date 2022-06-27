pragma solidity ^0.5.8;

contract SimpleAuction {

    address payable public beneficiary; // 판매자

    uint public auctionClosingTime; // 초기 경매 진행시간

    address public highestBidder; // 가장 높게 부른 구매자

    uint public highestBid; // 가장 높게 부른 구매자의 입찰금액

    mapping(address => uint) pendingReturns; // 응찰된 금액

    bool ended; // 경매 종료 결과

    event HighestBidIncreased(address bidder, uint amount);  // 가장 높게 응찰한 금액과 구매자 로그기록

    event AuctionEnded(address winner, uint amount); // 경매 마감후 가장 높게 응찰한 금액과 구매자 로그기록

    constructor (uint _biddingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        auctionClosingTime = now + _biddingTime;
    }

    // 입찰
    function bid() public payable {
        // 경매 종료시간이 남은 경우
        require(now <= auctionClosingTime);
        
        // 입찰한 금액이 최고 입찰 금액보다 클 경우
        require(msg.value > highestBid);

        // 최고 입찰 금액이 존재할 경우
        if(highestBid != 0) {
            // 기존 최금 입찰 금액을 누적함
            pendingReturns[highestBidder] += highestBid;
        }

        // 새로운 최고 입찰 금액 저장
        highestBidder = msg.sender;
        highestBid = msg.value;

        // 새로운 최고 입찰 금액 로그 기록
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // 인출
    function withdraw() public returns(bool) {
        // 같은 주소값을 가진 응찰된 금액 조회
        uint amount = pendingReturns[msg.sender];

        // 응찰 금액이 있을 경우
        if(amount > 0) {
            // 응찰 금액 초기화(다시 호출시 중복으로 빠져나가는 경우 방지)
            pendingReturns[msg.sender] = 0;

            // 송금시 오류발생한 경우
            if(!msg.sender.send(amount)) {
                // 응찰 금액 다시 넣어줌
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        // 경매가 아직 끝나지 않았을 때
        require(now >= auctionClosingTime);

        // 해당 함수가 이미 호출되었는지 파악
        require(!ended);

        ended = true;
        // 경매 종료후 가장 높은 비더와 응찰가격을 돌려줌
        emit AuctionEnded(highestBidder, highestBid);
        
        // 판마재에게 가장 높은 금액 전송
        beneficiary.transfer(highestBid);
    }
}

// 궁금한 점
// event 작동 원리