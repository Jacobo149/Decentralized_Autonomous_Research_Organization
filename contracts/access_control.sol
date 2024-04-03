/*
- Include contracts to manage access control, permissions, and security features within the DARO ecosystem.
- Implement role-based access control mechanisms to ensure appropriate permissions for different actions within the organization.
- Enhance contract security through proper authorization checks and protection against common vulnerabilities.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AccessControl is Ownable {
    mapping(address => bool) public admins;
    mapping(address => bool) public researchers;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event ResearcherAdded(address indexed researcher);
    event ResearcherRemoved(address indexed researcher);

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    modifier onlyResearcher() {
        require(researchers[msg.sender], "Not a researcher");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function addResearcher(address _researcher) external onlyAdmin {
        researchers[_researcher] = true;
        emit ResearcherAdded(_researcher);
    }

    function removeResearcher(address _researcher) external onlyAdmin {
        researchers[_researcher] = false;
        emit ResearcherRemoved(_researcher);
    }
}
