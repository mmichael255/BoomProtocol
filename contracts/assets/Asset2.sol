// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Asset2 is ERC20, ERC20Burnable {
    constructor() ERC20("Asset2", "a2") {
        _mint(msg.sender, 100 ether);
    }
}
