/*
- Create a native token for the DARO ecosystem to represent voting rights and ownership within the organization.
- Implement features such as token issuance, transfer, and voting power calculation based on token holdings.
- Integrate with the DAO core contract for governance and voting functionalities.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAROToken is ERC20 {
    address public admin;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        admin = msg.sender; // Set contract deployer as admin
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyAdmin {
        _burn(account, amount);
    }
}
