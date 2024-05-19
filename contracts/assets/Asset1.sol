// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Asset1 is ERC20, ERC20Burnable {
    constructor(address[] memory users) ERC20("Asset1", "a1") {
        for (uint256 i = 0; i < users.length; i++) {
            _mint(users[i], 100 ether);
        }
    }
}
