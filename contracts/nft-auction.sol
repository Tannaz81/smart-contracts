// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to;
        uint _nftId
    ) external ;
}

contract NftAuction {
    uint private constant duration = 8 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discounRate;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discounRate = _discountRate; 
        startAt = block.timestamp;
        expiresAt = block.timestamp + duration;

        require(_startingPrice >= _discountRate * duration, "starting price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns(uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate + timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transferFrom(refund);
        }
        selfdestruct(seller);
    }
}