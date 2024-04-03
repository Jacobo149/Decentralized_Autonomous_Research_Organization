/*
- If the DARO incentivizes participation through token rewards, develop a contract to distribute governance rewards to active participants.
- Implement mechanisms for calculating and distributing rewards based on contributions such as voting, proposal submission, or project management.
- Ensure fairness and transparency in reward distribution algorithms.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GovernanceRewardDistribution is Ownable {
    struct Contributor {
        uint256 totalContributions;
        uint256 lastRewardTimestamp;
    }

    mapping(address => Contributor) public contributors;
    IERC20 public daroToken; // DARO token contract address
    uint256 public rewardRate; // Governance reward rate per second
    uint256 public rewardPerTokenStored; // Reward per token accumulated
    uint256 public lastUpdateTime; // Last time rewardPerTokenStored was updated

    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(address _daroToken, uint256 _rewardRate) {
        daroToken = IERC20(_daroToken);
        rewardRate = _rewardRate;
    }

    modifier updateReward(address _user) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_user != address(0)) {
            contributors[_user].totalContributions = earned(_user);
            contributors[_user].lastRewardTimestamp = block.timestamp;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < lastUpdateTime ? block.timestamp : lastUpdateTime;
    }

    function rewardPerToken() public view returns (uint256) {
        if (daroToken.totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / daroToken.totalSupply());
    }

    function earned(address _user) public view returns (uint256) {
        return contributors[_user].totalContributions * (rewardPerToken() - contributors[_user].lastRewardTimestamp);
    }

    function claimReward() external updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        require(reward > 0, "No reward to claim");
        daroToken.transfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    function addReward(uint256 _reward) external onlyOwner updateReward(address(0)) {
        daroToken.transferFrom(msg.sender, address(this), _reward);
        emit RewardAdded(_reward);
    }
}
