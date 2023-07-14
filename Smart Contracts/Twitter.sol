// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract TweetContract{
    struct Tweet{
        uint id;
        address author;
        string content;
        uint createdAt;
    }
    struct Message{
        uint id;
        string content;
        address from;
        address to;
        uint createdAt; 
    }

    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[]) public tweetsOf;
    mapping(address=>Message[]) public conversations;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping(address=>address[]) public following;

    uint nextId;
    uint nextMessageId;

    function _tweet(address _from,string calldata _content) internal{
        tweets[nextId]=Tweet(nextId,_from,_content,block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId++;
    }
    function _sendMessage(address _from,address _to,string calldata _content) internal{
        conversations[_from].push(Message(nextMessageId,_content,_from,_to,block.timestamp));
        nextMessageId++;
    }

    function tweet(string calldata _content) public{
        _tweet(msg.sender,_content);
    }
    function tweet(address _from,string calldata _content) public{
        _tweet(_from,_content);
    }
    function sendMessage(address _to,string calldata _content) public{
        _sendMessage(msg.sender,_to,_content);
    }
    function sendMessage(address _from,address _to,string calldata _content) public{
        _sendMessage(_from,_to,_content);
    }
    function follow(address _followed) public{
        following[msg.sender].push(_followed);
    }
    function allow(address _operator) public{
        operators[msg.sender][_operator]=true;
    }
    function disallow(address _operator) public{
        operators[msg.sender][_operator]=false;
    }
    function getLatestTweets(uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=nextId,"Count is not proper");
        Tweet[] memory arr=new Tweet[](count);
        uint j;
        for(uint i=nextId-count;i<nextId;i++){
               arr[j]=tweets[i];
               j++;
        }
        return arr;
    }
    function getUserTweets(address _user,uint count) public view returns(Tweet[] memory){
        require(count>0 && count<=tweetsOf[_user].length,"Count is not proper");
        Tweet[] memory arr=new Tweet[](count);
        uint j;
        for(uint i=tweetsOf[_user].length-count;i<tweetsOf[_user].length;i++){
                 arr[j]=tweets[tweetsOf[_user][i]];
                 j++;
        }
        return arr;
    }
}