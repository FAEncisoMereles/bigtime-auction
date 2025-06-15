// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BigTimeItemAuction
 * @dev Auction contract for Big Time game item upgrades.
 */
contract BigTimeItemAuction {
    string public itemName;
    uint256 public auctionEnd;
    uint256 public constant MIN_BID_INCREMENT = 105; // 5% increment
    uint256 public constant COMMISSION_PERCENT = 2;
    uint256 public constant EXTENSION_TIME = 10 minutes;

    address private immutable owner;

    struct Bid {
        uint256 amount;
        bool refunded;
    }

    mapping(address => Bid[]) private bids;
    mapping(address => uint256) public currentTotalBid;
    address[] public bidders;

    address public highestBidder;
    uint256 public highestBid;
    bool public auctionEnded;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "notOwner");
        _;
    }

    modifier auctionActive() {
        require(block.timestamp < auctionEnd, "ended");
        require(!auctionEnded, "auctionOver");
        _;
    }

    modifier auctionFinished() {
        require(block.timestamp >= auctionEnd || auctionEnded, "notOver");
        _;
    }

    constructor(string memory _itemName, uint256 _durationSeconds) {
        require(_durationSeconds > 0, "invalidTime");
        itemName = _itemName;
        owner = msg.sender;
        auctionEnd = block.timestamp + _durationSeconds;
    }

    function placeBid() external payable auctionActive {
        uint256 newTotal = currentTotalBid[msg.sender] + msg.value;
        require(newTotal >= (highestBid * MIN_BID_INCREMENT) / 100, "lowBid");

        if (currentTotalBid[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        currentTotalBid[msg.sender] = newTotal;
        bids[msg.sender].push(Bid(msg.value, false));

        if (block.timestamp + EXTENSION_TIME > auctionEnd) {
            auctionEnd = block.timestamp + EXTENSION_TIME;
        }

        highestBidder = msg.sender;
        highestBid = newTotal;

        emit NewBid(msg.sender, newTotal);
    }

    function getWinner() external view auctionFinished returns (address, uint256) {
        return (highestBidder, highestBid);
    }

    function getAllBids() external view returns (address[] memory, uint256[] memory) {
        uint256[] memory amounts = new uint256[](bidders.length);
        for (uint256 i = 0; i < bidders.length; i++) {
            amounts[i] = currentTotalBid[bidders[i]];
        }
        return (bidders, amounts);
    }

    function withdraw() external auctionFinished {
        require(msg.sender != highestBidder, "winnerNoWithdraw");
        uint256 amount = currentTotalBid[msg.sender];
        require(amount > 0, "nothing");

        currentTotalBid[msg.sender] = 0;
        _sendETH(msg.sender, amount);
    }

    function partialRefund() external auctionActive {
        Bid[] storage userBids = bids[msg.sender];
        uint256 refundAmount = 0;

        for (uint256 i = 0; i < userBids.length - 1; i++) {
            if (!userBids[i].refunded) {
                refundAmount += userBids[i].amount;
                userBids[i].refunded = true;
            }
        }

        require(refundAmount > 0, "nothing");
        currentTotalBid[msg.sender] -= refundAmount;
        _sendETH(msg.sender, refundAmount);
    }

    function finalizeAuction() external auctionFinished {
        require(!auctionEnded, "alreadyEnded");
        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);

        uint256 commission = (highestBid * COMMISSION_PERCENT) / 100;
        _sendETH(owner, highestBid - commission);
    }

    function emergencyWithdraw(uint256 amount) external onlyOwner {
        _sendETH(owner, amount);
    }

    function _sendETH(address to, uint256 amount) internal {
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "sendFail");
    }

    receive() external payable {}
}

