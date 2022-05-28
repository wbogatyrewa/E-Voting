// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "./Token.sol";

contract Voting {

    string name;

    uint startTime;

    uint endTime;

    mapping (address => bool) voters; // {address of voter => voted}
    mapping (address => bool) votersExist;

    mapping (address => string) proposals; // {address of proposal => name of proposal}
    mapping (address => bool) proposalsExist;

    address chairperson;

    Token token = new Token();

    constructor (string memory _name, uint _startTime, uint _endTime) {
        name = _name;
        chairperson = msg.sender; // owner
        startTime = _startTime;
        endTime = _endTime; 
    }

    modifier onlyChairperson() {
        require(msg.sender == chairperson, 
                "This isn't chairperson.");
        _;
    }

    modifier voteIsOn() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, 
                "Voting completed.");
        _;
    }

    function addVoters(address[] memory _voters) public onlyChairperson {
        for (uint i = 0; i < _voters.length; i++) {
            require(!proposalsExist[_voters[i]], "Proposal can't be voter.");
            require(!votersExist[_voters[i]], "Voter exists.");
    
            voters[_voters[i]] = false;
            votersExist[_voters[i]] = true;
            token.mint(_voters[i], 1); 
        }
        require(!proposalsExist[chairperson], "Proposal can't be chairperson.");
        require(!votersExist[chairperson], "Voter exists.");
        voters[chairperson] = false;
        votersExist[chairperson] = true;
        token.mint(chairperson, 1); 
        
    }

    function addProposals(address[] memory _proposalsAddr, 
                          string[] memory _proposalsNames) public onlyChairperson {
        require(_proposalsAddr.length == _proposalsNames.length, "Length is different.");

        for (uint i = 0; i < _proposalsAddr.length; i++) {
            require(msg.sender != _proposalsAddr[i], "Chairperson can't be proposal.");
            require(!votersExist[_proposalsAddr[i]], "Voter can't be proposal.");
            
            proposals[_proposalsAddr[i]] = _proposalsNames[i];
            proposalsExist[_proposalsAddr[i]] = true;
        }
    }

    function vote(address proposal) public voteIsOn {
        require(votersExist[msg.sender], "Voter doesn't exist.");
        require(token.balanceOf(msg.sender) > 0, "Token doesn't exist.");
        require(proposalsExist[proposal], "Proposal doesn't exist.");
        require(!voters[msg.sender], "Voter already voted.");
        require(!votersExist[proposal], "Voter can't be proposal.");
        
        token.transfer(proposal, token.balanceOf(msg.sender));
        voters[msg.sender] = true;
    }

    function totalVotesFor(address proposal) view public returns (uint256) {
        require(block.timestamp >= endTime, "Voting has not ended.");
        require(proposalsExist[proposal], "Proposal doesn't exist.");
        
        return token.balanceOf(proposal);
    }

    function nameOfProposal(address proposal) view public returns (string memory) {
        require(proposalsExist[proposal], "Proposal doesn't exist.");
        
        return proposals[proposal];
    }
} 