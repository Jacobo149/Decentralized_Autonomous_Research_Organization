/*
- This contract serves as the core of the DARO, managing overall governance, voting mechanisms, and membership management.
- It should include functions for proposing, voting on, and executing decisions such as funding research projects or changing DAO parameters.
- Implement mechanisms for membership management, including joining, leaving, and voting rights.
- Include features for voting delegation and stake-based governance if desired.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOCore is Ownable {
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => bool) voters;
    }

    uint256 public proposalCount;
    uint256 public votingDuration;
    uint256 public minVotesRequired;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;

    event ProposalCreated(uint256 id, address proposer, string description);
    event Voted(uint256 proposalId, address voter, bool inSupport);
    event ProposalExecuted(uint256 id);

    constructor(uint256 _votingDuration, uint256 _minVotesRequired) Ownable() {
        votingDuration = _votingDuration;
        minVotesRequired = _minVotesRequired;
        // Set contract deployer as initial member
        members[msg.sender] = true;
    }

    function propose(string memory _description) external {
        require(!members[msg.sender], "Only non-members can propose");
        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.id = proposalCount;
        proposal.proposer = msg.sender;
        proposal.description = _description;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + votingDuration;
        emit ProposalCreated(proposalCount, msg.sender, _description);
    }

    function vote(uint256 _proposalId, bool _inSupport) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.endTime, "Voting period ended");
        require(!proposal.voters[msg.sender], "Already voted");
        proposal.voters[msg.sender] = true;
        if (_inSupport) {
            proposal.votesFor += 1;
        } else {
            proposal.votesAgainst += 1;
        }
        emit Voted(_proposalId, msg.sender, _inSupport);
    }

    function execute(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(block.timestamp >= proposal.endTime, "Voting period not ended");
        require(proposal.votesFor >= minVotesRequired, "Not enough votes for proposal");
        proposal.executed = true;
        // Execute proposal actions here
        emit ProposalExecuted(_proposalId);
    }

    function addMember(address _member) external onlyOwner {
        require(!members[_member], "Address already a member");
        members[_member] = true;
    }

    function removeMember(address _member) external onlyOwner {
        require(members[_member], "Address not a member");
        delete members[_member];
    }
}

