// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Auction{
    address auctioneer;
    uint nextItemId;
    bool start;
    struct Item{
        uint id;
        string description;
        uint highest_bid;
        address highest_bidder;
    }
    struct Bid{
        uint bid;
        address bidder;
    }
    mapping(uint=>Item) ItemDetails;
    mapping(uint=>Bid) BidDetails;

    constructor(){
        auctioneer=msg.sender;
    }
    
    modifier onlyAuctioneer(){
        require(msg.sender==auctioneer,"You are not the auctioneer");
        _;
    }

    function placeItem(uint _id,string calldata _description) public onlyAuctioneer{
        require(nextItemId<3,"You cannot place any more item");
        ItemDetails[_id].id=_id;
        ItemDetails[_id].description=_description;
        nextItemId++;
    }
    function startAuction() public onlyAuctioneer{
        require(nextItemId==3,"All items are not yet placed");
        start=true;
    }
    function updateBid(uint _id,address bidder,uint bid) internal{
        ItemDetails[_id].highest_bidder=bidder;
        ItemDetails[_id].highest_bid=bid;
        BidDetails[_id]=Bid(bid,bidder);
    }
    function placeBid(uint _id,uint bid) public{
        require(start==true,"Auction has not yet started");
        require(msg.sender!=auctioneer,"You are the auctioneer");
        require(_id>0 && _id<4,"Invalid item id");
        require(bid>ItemDetails[_id].highest_bid,"Bid more than the current bid");
        updateBid(_id,msg.sender,bid);
    }
    function currentBid(uint _id) public view returns(Bid memory){
        return BidDetails[_id];
    }
    function getter(uint _id) public view returns(Item memory){
         return ItemDetails[_id]; 
    }
}