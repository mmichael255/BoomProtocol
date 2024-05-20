// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Asset2 is ERC20, ERC20Burnable {
    address private _admin;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Must Be Admin");
        _;
    }

    constructor() ERC20("Asset2", "a2") {
        _admin = msg.sender;
    }

    function initial(address[] memory users) external onlyAdmin {
        for (uint256 i = 0; i < users.length; i++) {
            _mint(users[i], 100 ether);
        }
    }
}
