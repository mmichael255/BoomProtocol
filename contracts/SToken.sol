// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract SToken is ERC20("ShareToken", "st"), ERC20Burnable {
    using SafeERC20 for IERC20;

    address private _admin;
    address private _pool;
    address private _underlyingAsset;

    event MINT(address indexed user, uint256 indexed amount);
    event BURN(address indexed user, uint256 indexed amount);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Must Be Admin");
        _;
    }

    constructor() {
        _admin = msg.sender;
    }

    function initial(address pool, address underlyingAsset) external onlyAdmin {
        _pool = pool;
        _underlyingAsset = underlyingAsset;
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

    function transferUnderlyingTo(
        address to,
        uint256 amount
    ) external onlyPool returns (uint256) {
        IERC20(_underlyingAsset).safeTransfer(to, amount);
        return amount;
    }

    function burn(
        address from,
        address to,
        uint256 amount,
        uint256 index
    ) external onlyPool {
        uint256 burnAmount = amount / index;
        _burn(from, burnAmount);
        IERC20(_underlyingAsset).safeTransfer(to, amount);

        emit BURN(from, burnAmount);
    }

    function getAdmin() external view returns (address) {
        return _admin;
    }

    function getPool() external view returns (address) {
        return _pool;
    }
}
