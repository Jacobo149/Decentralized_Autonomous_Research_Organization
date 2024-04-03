/*
- Develop a contract to manage intellectual property rights associated with research outputs generated within the DARO.
- Include functions for registering intellectual property, licensing agreements, and revenue distribution.
- Implement features for enforcing copyright, patent, or other IP protections as per the DAO's policies.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract IntellectualPropertyManagement is Ownable {
    enum IPType {Copyright, Patent}

    struct IPRecord {
        IPType ipType;
        address owner;
        string description;
        uint256 timestamp;
    }

    mapping(uint256 => IPRecord) public ipRecords;
    uint256 public ipCount;

    event IPRegistered(uint256 indexed ipId, IPType ipType, address indexed owner, string description);

    function registerIP(IPType _ipType, string memory _description) external {
        ipCount++;
        IPRecord storage newRecord = ipRecords[ipCount];
        newRecord.ipType = _ipType;
        newRecord.owner = msg.sender;
        newRecord.description = _description;
        newRecord.timestamp = block.timestamp;
        emit IPRegistered(ipCount, _ipType, msg.sender, _description);
    }

    function transferIP(uint256 _ipId, address _newOwner) external {
        require(msg.sender == ipRecords[_ipId].owner, "Not the IP owner");
        ipRecords[_ipId].owner = _newOwner;
    }
}
