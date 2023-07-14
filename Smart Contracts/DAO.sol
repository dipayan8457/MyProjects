// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract DAOContract{

    struct Proposal{
        uint id;
        string description;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool isExecuted;
    }

    mapping(address=>bool) private isInvestor;
    mapping(address=>uint) public numOfshares;
    mapping(address=>mapping(uint=>bool)) public isVoted;
    mapping(address=>mapping(address=>bool)) public withdrawlStatus;
    address[] public investorsList;
    mapping(uint=>Proposal) public proposals;

    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quoram;
    address public manager;

    constructor(uint _contributionTimeEnd,uint _voteTime,uint _quoram){
        require(_quoram>0 && _quoram<100,"Not valid value");
        contributionTimeEnd=block.timestamp+_contributionTimeEnd;
        voteTime=_voteTime;
        manager=msg.sender;
    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true,"You are not an investor");
        _;
    }
    modifier onlyManager(){
        require(manager==msg.sender,"You are not the manager");
        _;
    }

    function contribution() external payable{
        require(block.timestamp<contributionTimeEnd,"Contribution Time Ended");
        require(msg.value>0,"Send more than 0 ether");
        isInvestor[msg.sender]=true;
        numOfshares[msg.sender]+=msg.value;
        totalShares+=msg.value;
        availableFunds+=msg.value;
        investorsList.push(msg.sender);
    }
    function redeemShares(uint amount) external onlyInvestor{
        require(amount<=numOfshares[msg.sender],"You don't have enough shares");
        require(amount<=availableFunds,"Not enough funds");
        numOfshares[msg.sender]-=amount;
        totalShares-=amount;
        availableFunds-=amount;
        if(numOfshares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        payable(msg.sender).transfer(amount);
    }
    function transferShare(uint amount,address to) public onlyInvestor{
       require(amount<=numOfshares[msg.sender],"You don't have enough shares");
       numOfshares[msg.sender]-=amount;
       if(numOfshares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        numOfshares[to]+=amount; 
        isInvestor[to]=true;
    } 
    function createProposal(string calldata _description,uint _amount,address payable _recipient) public onlyManager{
        require(_amount<=availableFunds,"Not enough funds");
        proposals[nextProposalId]=Proposal(nextProposalId,_description,_amount,_recipient,0,block.timestamp+voteTime,false);
        nextProposalId++;
    }
    function voteProposal(uint proposalId) public onlyInvestor{
        require(block.timestamp<proposals[proposalId].end,"Voting Time Ended");
        require(isVoted[msg.sender][proposalId]==false,"You have already voted for this proposal");
        require(proposals[proposalId].isExecuted==false,"It is already executed");
        isVoted[msg.sender][proposalId]=true;
        proposals[proposalId].votes+=numOfshares[msg.sender];
    }
    function executeProposal(uint proposalId) public onlyManager{
        require(((proposals[proposalId].votes*100)/totalShares)>=quoram,"Majority does not support");
        proposals[proposalId].isExecuted=true;
        availableFunds-=proposals[proposalId].amount;
        _transfer(proposals[proposalId].amount,proposals[proposalId].recipient);
    }
    function _transfer(uint _amount,address payable _recipient) private{
        _recipient.transfer(_amount);
    }
    function proposalList() public view returns(Proposal[] memory){
        Proposal[] memory array=new Proposal[](nextProposalId);
        for(uint i=0;i<nextProposalId;i++){
            array[i]=proposals[i];
        }
        return array;
    }
}