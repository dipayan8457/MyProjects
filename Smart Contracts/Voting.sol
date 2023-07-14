// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract VotingContract{
    address electionCommission;
    address public winner;

    struct Voter{
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }
    struct Candidate{
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }

    uint nextVoterId=1;
    uint nextCandidateId=1;
    bool stopVoting;

    uint startTime;
    uint endTime;

    constructor(){
        electionCommission=msg.sender;
    }

    mapping(uint=>Voter) voterDetails;
    mapping(uint=>Candidate) candidateDetails;

    modifier isVotingOver(){
        require(endTime>block.timestamp && !stopVoting,"Voting is over");
        _;
    }
    modifier onlyCommissioner(){
        require(electionCommission==msg.sender,"Not from election commission");
        _;
    }

    function candidateRegister(string calldata _name,string calldata _party,uint _age,string calldata _gender) external{
        require(msg.sender!=electionCommission,"You are from election commission");
        require(candidateVerification(msg.sender),"Candidate Already Registered");
        require(_age>=18,"You are not eligible");
        require(nextCandidateId<3,"Candidate Registration Full");
        candidateDetails[nextCandidateId]=Candidate(_name,_party,_age,_gender,nextCandidateId,msg.sender,0);
        nextCandidateId++;
    }
    function candidateVerification(address _person) internal view returns(bool){
        for(uint i=1;i<nextCandidateId;i++){
            if(candidateDetails[i].candidateAddress==_person){
                return false;
            }
        }
        return true;
    }
    function candidateList() public view returns(Candidate[] memory){
        Candidate[] memory array=new Candidate[](nextCandidateId-1);
        for(uint i=0;i<nextCandidateId-1;i++){
            array[i]=candidateDetails[i+1];
        }
        return array;
    }
    function voterRegister(string calldata _name,uint _age,string calldata _gender) external{
        require(voterVerification(msg.sender),"Voter Already Registered");
        require(_age>=18,"You are not eligible");
        voterDetails[nextVoterId]=Voter(_name,_age,nextVoterId,_gender,0,msg.sender);
        nextVoterId++;
    }
    function voterVerification(address _person) internal view returns(bool){
        for(uint i=1;i<nextVoterId;i++){
            if(voterDetails[i].voterAddress==_person){
                return false;
            }
        }
        return true;
    }
    function voterList() public view returns(Voter[] memory){
        Voter[] memory array=new Voter[](nextVoterId-1);
        for(uint i=0;i<nextVoterId-1;i++){
            array[i]=voterDetails[i+1];
        }
        return array;
    }
    function vote(uint _voterId,uint _id) external isVotingOver{
        require(voterDetails[_voterId].voteCandidateId==0,"Already voted");
        require(voterDetails[_voterId].voterAddress==msg.sender,"You are not a voter");
        require((block.timestamp>startTime && startTime!=0),"Voting has not started");
        require(block.timestamp<endTime,"Voting has ended");
        require(nextCandidateId==3,"Candidate registration not done yet");
        require(_id>0 && _id<3,"Invalid candidate id");
        voterDetails[_voterId].voteCandidateId=_id;
        candidateDetails[_id].votes++;
    }
    function voteTime(uint _startTime,uint _endTime) external onlyCommissioner{
        startTime=block.timestamp+_startTime;
        endTime=startTime+_endTime;
    }
    function votingStatus() public view returns(string memory){
        if(block.timestamp<startTime || startTime==0){
               return "Voting has not started";
        }
        else if((block.timestamp>startTime && block.timestamp<endTime) && stopVoting==false){
            return "Voting is in progress";
        }
        else{
            return "Voting has ended";
        }
    }
    function result() external onlyCommissioner{
        if(candidateDetails[1].votes>candidateDetails[2].votes){
            winner=candidateDetails[1].candidateAddress;
        }
        else{
            winner=candidateDetails[2].candidateAddress;
        }
    }
    function emergency() public onlyCommissioner{
        stopVoting=true;
    }

}