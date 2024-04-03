/*
- Each research project proposed to the DARO should have its own contract to manage project-specific details and interactions.
- Include functions for submitting project proposals, reviewing proposals, and voting on whether to fund them.
- Implement features for project milestones, updates, and fund allocation based on voting outcomes.
- Include mechanisms for tracking project progress and disbursing funds accordingly.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ProjectProposal is Ownable {
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

    event ProposalCreated(uint256 id, address proposer, string description);
    event Voted(uint256 proposalId, address voter, bool inSupport);
    event ProposalExecuted(uint256 id);

    constructor(uint256 _votingDuration, uint256 _minVotesRequired) {
        votingDuration = _votingDuration;
        minVotesRequired = _minVotesRequired;
    }

    function propose(string memory _description) external {
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
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
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
}
