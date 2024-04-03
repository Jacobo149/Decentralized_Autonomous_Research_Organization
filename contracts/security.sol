/*
- Include contracts to manage access control, permissions, and security features within the DARO ecosystem.
- Implement role-based access control mechanisms to ensure appropriate permissions for different actions within the organization.
- Enhance contract security through proper authorization checks and protection against common vulnerabilities.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SecurityContract is Ownable {
    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isMember;
    
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event MemberAdded(address indexed member);
    event MemberRemoved(address indexed member);

    constructor() {
        isAdmin[msg.sender] = true;
        isMember[msg.sender] = true;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Sender is not an admin");
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender], "Sender is not a member");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {
        isAdmin[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != msg.sender, "Cannot remove self");
        isAdmin[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function addMember(address _member) external onlyAdmin {
        isMember[_member] = true;
        emit MemberAdded(_member);
    }

    function removeMember(address _member) external onlyAdmin {
        require(_member != msg.sender, "Cannot remove self");
        isMember[_member] = false;
        emit MemberRemoved(_member);
    }
}
