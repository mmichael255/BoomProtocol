// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SToken is ERC20("ShareToken", "st"), ERC20Burnable {
    address private _admin;
    address private _pool;

    event MINT(address indexed user, uint256 indexed amount);
    event BURN(address indexed user, uint256 indexed amount);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Must Be Admin");
        _;
    }

    constructor() {
        _admin = msg.sender;
    }

    function initial(address pool) external onlyAdmin {
        _pool = pool;
    }

    modifier onlyPool() {
        require(msg.sender == _pool, "Must Be Pool");
        _;
    }

    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external onlyPool returns (bool) {
        uint256 previousBalance = super.balanceOf(user);
        uint256 mintAmount = amount / index;
        _mint(user, mintAmount);
        emit MINT(user, mintAmount);
        return previousBalance == 0;
    }

    function burn(
        address user,
        uint256 amount,
        uint256 index
    ) external onlyPool {
        uint256 burnAmount = amount / index;
        _burn(user, burnAmount);
        emit BURN(user, burnAmount);
    }

    function getAdmin() external view returns (address) {
        return _admin;
    }

    function getPool() external view returns (address) {
        return _pool;
    }
}
