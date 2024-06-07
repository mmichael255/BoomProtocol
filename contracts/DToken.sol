// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DToken is ERC20("DebtToken", "dt"), ERC20Burnable {
    address private _admin;
    address private _pool;
    address private _underlyingAsset;

    mapping(address => uint256) _timeStamp;
    mapping(address => uint256) _userRate;

    uint256 internal constant SECONDS_PER_YEAR = 365 days;
    uint256 internal constant rateDecimals = 1e18;

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
        uint256 interestRate
    ) external onlyPool returns (bool) {
        //calculate the user balance so far (previous balance + interest)
        (
            uint256 currentBalance,
            uint256 increasedBalance
        ) = _calculateUserBalance(user);

        //set user borrow timestamp
        _timeStamp[user] = block.timestamp;
        //set user interest Rate
        uint256 mintAmount = amount;

        //mint amount + increased balance
        _mint(user, mintAmount);
        emit MINT(user, mintAmount);
        return currentBalance == 0;
    }

    /**
     * @dev Calculates the current user debt balance
     * @return The accumulated debt of the user
     * (1+x)^n
     **/
    function balanceOf(address user) public view override returns (uint256) {
        uint256 userBalance = super.balanceOf(user);
        if (userBalance == 0) {
            return 0;
        }
        uint256 compoundedInterestRate = _calculateCompoundedInterest(
            _userRate[user],
            _timeStamp[user]
        );
        return userBalance * (compoundedInterestRate / rateDecimals);
    }

    function _calculateCompoundedInterest(
        uint256 rate,
        uint256 lastUpdateTime
    ) returns (uint256) {
        uint256 ratePreSecond = rate / SECONDS_PER_YEAR;
        uint256 period = block.timestamp - lastUpdateTime;
        //(1+ratePreSecond) power period

        //
    }

    function _calculateUserBalance(
        address user
    ) internal view returns (uint256, uint256) {
        uint256 previousBalance = super.balanceOf(user);
        if (previousBalance == 0) {
            return (0, 0);
        }
        uint256 currentBalance = balanceOf(user);
        return (currentBalance, (currentBalance - previousBalance));
    }
}
