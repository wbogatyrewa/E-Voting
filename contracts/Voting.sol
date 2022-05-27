// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "./Token.sol";

contract Voting {

    string name;

    uint startTime;

    uint endTime;

    mapping (address => bool) voters; // {address of voter => voted}

    mapping (address => string) proposals; // {address of proposal => name of proposal}

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
            voters[_voters[i]] = false;
            token.mint(_voters[i], 1); 
        }
        if (token.balanceOf(chairperson) == 0) {
            token.mint(chairperson, 1); 
        }
    }

    function addProposals(address[] memory _proposalsAddr, 
                          string[] memory _proposalsNames) public onlyChairperson {
        require(_proposalsAddr.length == _proposalsNames.length, "Length is different.");

        for (uint i = 0; i < _proposalsAddr.length; i++) {
            if (msg.sender != _proposalsAddr[i]) {
                proposals[_proposalsAddr[i]] = _proposalsNames[i];
            }
            
        }
    }

    function vote(address proposal) public voteIsOn {
        require(token.balanceOf(msg.sender) > 0, "Token doesn't exist.");
        require(!voters[msg.sender], "Voter already voted.");
        require(bytes(proposals[proposal]).length > 0 , "This address does not exist among the candidates.");
        //require(voter[msg.sender], "Voter doesn't exist.");
        
        token.transfer(proposal, token.balanceOf(msg.sender));
        voters[msg.sender] = true;
    }

    function totalVotesFor(address proposal) view public returns (uint256) {
        require(block.timestamp >= endTime, "Voting has not ended.");
        require(bytes(proposals[proposal]).length > 0 , "This address does not exist among the candidates.");
        return token.balanceOf(proposal);
    }
}