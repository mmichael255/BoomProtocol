// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {UserInfoUpdate} from "./libraries/UserInfoUpdate.sol";
import {Calculate} from "./libraries/Calculate.sol";
import {SToken} from "./SToken.sol";
import {DToken} from "./DToken.sol";
import {Errors} from "./libraries/Errors.sol";

contract BoomPool {
    using SafeERC20 for IERC20;
    using UserInfoUpdate for DataTypes.UserData;

    address private _admin;
    uint256 private _assetCount;

    mapping(uint256 => address) private _assetList;
    mapping(address => DataTypes.AssetData) private _assetInfo;
    mapping(address => DataTypes.UserData) private _userInfo;

    event Deposit(
        address indexed user,
        address indexed asset,
        uint256 indexed amount
    );
    event Borrow(
        address indexed user,
        address indexed asset,
        uint256 indexed amount
    );
    event Withdraw(
        address user,
        address indexed to,
        address indexed asset,
        uint256 indexed amount
    );

    constructor() {
        _admin = msg.sender;
    }

    modifier onlyAdmin() {
        if (msg.sender != _admin) {
            revert Errors.BP__MustBeAdmin();
        }
        _;
    }

    function deposit(address asset, uint256 amount) public {
        DataTypes.AssetData storage assetData = _assetInfo[asset];
        if (!assetData.isActive) {
            revert Errors.BP__AssertNotActive();
        }
        //Could update assetData state, all kinds of index(not yet done)
        address sTokenAddr = assetData.sTokenAddress;
        IERC20(asset).safeTransferFrom(msg.sender, sTokenAddr, amount);
        bool isFirst = SToken(sTokenAddr).mint(
            msg.sender,
            amount,
            assetData.assetIndex
        );
        if (isFirst) {
            _userInfo[msg.sender].setDepositAssert(assetData.id, true);
        }
        emit Deposit(msg.sender, asset, amount);
    }

    function withdraw(address asset, uint256 amount, address to) public {
        //get asset data: Stoken address DToken address
        DataTypes.AssetData storage assetData = _assetInfo[asset];
        address sTokenAddress = assetData.sTokenAddress;
        uint256 balanceOfUser = IERC20(sTokenAddress).balanceOf(msg.sender);
        if (amount > balanceOfUser || balanceOfUser == 0) {
            revert Errors.BoomPoolInsufficientSTokenBlance(
                msg.sender,
                amount,
                balanceOfUser
            );
        }
        //validate withdraw
        if (
            !(
                Calculate.isHealthFactorOkToDecrease(
                    asset,
                    _assetList,
                    _assetInfo,
                    _userInfo[msg.sender],
                    msg.sender,
                    _assetCount,
                    amount
                )
            )
        ) {
            revert Errors.BP__TransationNotAllowed();
        }
        if (amount == balanceOfUser) {
            //update collateral info
            _userInfo[msg.sender].setDepositAssert(assetData.id, false);
        }
        //withdraw to toAddress
        SToken(sTokenAddress).burn(
            msg.sender,
            to,
            amount,
            assetData.assetIndex
        );
        emit Withdraw(msg.sender, to, asset, amount);
    }

    function borrow(address asset, uint256 amount) public {
        DataTypes.AssetData storage assetData = _assetInfo[asset];
        if (!assetData.isActive) {
            revert Errors.BP__AssertNotActive();
        }
        //validata borrow
        if (
            !Calculate.isOkToBorrow(
                asset,
                _assetList,
                _assetInfo,
                _userInfo[msg.sender],
                msg.sender,
                _assetCount,
                amount
            )
        ) {
            revert Errors.BP__BorrowNotAllowed();
        }

        //insterest rate?
        bool isFirst = DToken(assetData.dTokenAddress).mint(msg.sender, amount);
        if (isFirst) {
            _userInfo[msg.sender].setBorrowAssert(assetData.id, true);
        }

        SToken(assetData.sTokenAddress).transferUnderlyingTo(
            msg.sender,
            amount
        );
        emit Borrow(msg.sender, asset, amount);
    }

    function repay() public {}

    function liquidation() public {}

    function addAssert(address assertAddr) public onlyAdmin {
        bool isAdded = _assetInfo[assertAddr].id != 0 ||
            _assetList[0] == assertAddr;
        if (!isAdded) {
            _assetList[_assetCount] = assertAddr;
            _assetInfo[assertAddr].id = uint8(_assetCount);
            _assetCount += 1;
        }
    }

    function initAssert(
        address assertAddr,
        address priceFeed,
        uint256 decimals,
        uint256 assetIndex,
        uint256 interestRate,
        address sToken,
        address dToken
    ) public onlyAdmin {
        DataTypes.AssetData storage assetData = _assetInfo[assertAddr];
        assetData.isActive = true;
        assetData.priceFeed = priceFeed;
        assetData.decimals = decimals;
        assetData.assetIndex = assetIndex;
        assetData.interestRate = interestRate;
        assetData.sTokenAddress = sToken;
        assetData.dTokenAddress = dToken;
    }

    function getAdmin() external view returns (address) {
        return _admin;
    }

    function getAssetFromList(uint256 index) external view returns (address) {
        return _assetList[index];
    }

    function getAssetInfo(
        address asset
    ) external view returns (DataTypes.AssetData memory) {
        return _assetInfo[asset];
    }
}
