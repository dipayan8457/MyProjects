// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Marketplace{
    uint nextItemId=1;
    struct Item{
        uint id;
        string name;
        string description;
        uint price;
        address payable seller;
        bool status;
    }
    mapping(uint=>Item) ItemDetails;

    event OrderPlaced(address from,uint id);
    event TransactionSuccessful(address from,address to,uint amount);

    function listItem(string calldata _name,string calldata _description,uint _price) public{
        ItemDetails[nextItemId]=Item(nextItemId,_name,_description,_price,payable(msg.sender),true);
        nextItemId++;
    }
    function searchItem(string calldata _description) public view returns(Item[] memory){
        Item[] memory arr=new Item[](nextItemId-1);
        bool found;
        uint j;
        for(uint i=1;i<nextItemId;i++){
            if(keccak256(abi.encodePacked(ItemDetails[i].description))==keccak256(abi.encodePacked(_description))){
                    arr[j]=ItemDetails[i];
                    j++;
                    found=true;
                }
        }
        require(found==true,"Item not found");
        return arr;
    }
    function orderItem(uint _id) public{
        require(ItemDetails[_id].seller!=msg.sender,"You are the seller");
        require(_id>0 && _id<nextItemId,"Invalid item id");
        require(ItemDetails[_id].status==true,"Item not available");
        require(ItemDetails[_id].price<=address(msg.sender).balance,"You do not have enough balance");
        emit OrderPlaced(msg.sender,_id);
    }  
    function completePayment(uint _id) public payable{
        uint price=ItemDetails[_id].price*10**18;
        require(msg.value==price,"Pay the correct price");
        ItemDetails[_id].seller.transfer(msg.value);
        emit TransactionSuccessful(msg.sender,ItemDetails[_id].seller,msg.value);
        ItemDetails[_id].status=false;
    }
}