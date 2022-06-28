pragma solidity ^0.5.8;

contract SimpleAuction {

    address payable public beneficiary; // 판매자

    uint public endTime; // 경매 진행시간(초 단위)

    address public highestBidder; // 가장 높게 부른 구매자

    uint public highestBid; // 가장 높게 부른 구매자의 입찰금액

    mapping(address => uint) pendingReturns; // 차순위 가격들을 등록하는 테이블(환불 처리를 위한)

    bool private ended; // 경매 진행 여부 - 기본값 false(0)

    event HighestBidIncreased(address bidder, uint amount); // 가장 높게 응찰한 금액과 구매자를 블록체인 로그에 기록
    // 페이로드에 로그가 기록되기때문에 이벤트 작성할떄 가스비가 많이 들어간다.

    event AuctionEnded(address winner, uint amount); // 경매 마감후 가장 높게 응찰한 금액과 구매자를 블록체인 로그에 기록

    // 초기 세팅(시간, 판매자)
    constructor (uint _biddingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        endTime = now + _biddingTime;
    }

    // 입찰
    function bid() public payable {
        // 경매 종료시간이 남은 경우
        require(now <= endTime);
        
        // 입찰한 금액이 최고 입찰 금액보다 클 경우
        require(msg.value > highestBid);

        // 기존 최고 입찰 금액이 존재할 경우
        if(highestBid != 0) {
            // 기존 최고 입찰 금액을 차순위 가격 등록 테이블에 누적하여 매핑
            // 왜 누적하여 매핑하는가?
            // A가 2번, B가 2번 총 4번의 입찰이 진행되었다고 가정해본다면, 
            // B가 10으로 입찰하고, A가 20으로 다시 입찰, 그 후 B가 30으로 입찰 한 뒤 A가 40으로 다시 입찰이
            // 진행되었다고 할때 
            // B가 처음 입찰하여 최고입찰자가 되면 최고입찰 금액도 변경됨
            // A가 입찰시 기존 최고 입찰자였던 B는 차순위로 밀리게 되고 해당 금액에 대한 정보는 차순위 등록 테이블에 기록 B => 10
            // B가 다시 입찰시 A는 차순위로 밀려 테이블에 기록이 됨 A => 20
            // 마지막으로 A가 입찰시 B는 차순위로 밀려 테이블에 기록이되는데 기존 금액에 추가가 되어야하므로 +=를 사용하여 매핑
            // 즉, B => 40이 되어야함 
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
        // 차 순위 가격 등록 테이블에 등록된 가격 조회하여 변수에 저장
        uint amount = pendingReturns[msg.sender];

        // 누적 금액이 있을 경우
        if(amount > 0) {
            // 누적 금액 초기화(다시 호출시 중복으로 빠져나가는 경우 방지)
            pendingReturns[msg.sender] = 0;

            // 송금시 오류발생한 경우
            // transfer 에러 발생시, 예외처리 되면서 이전 상태로 돌아감, 
            // 대상이 CA일 경우 폴백함수 호출 (require과 같은 기능)
            // 이더를 송금, 전송 실패시 컨트랙트 중지하지 않고, false 리턴
            // send 사용시 반드시 검증(return 값 체크) 필요
            if(!msg.sender.send(amount)) {
                // 응찰 금액 다시 넣어줌
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    // 경매 종료
    function auctionEnd() public {
        // 경매 진행시간이 종료되었을때
        require(now > endTime);

        // 해당 함수가 이미 호출되었는지 파악
        require(!ended);

        ended = true;

        // 경매 종료후 가장 높은 비더와 응찰가격을 돌려줌
        emit AuctionEnded(highestBidder, highestBid);
        
        // 판매자에게 가장 높은 금액 전송
        beneficiary.transfer(highestBid);
    }
}
