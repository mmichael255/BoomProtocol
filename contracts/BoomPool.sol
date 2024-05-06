// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {UserInfoUpdate} from "./libraries/UserInfoUpdate.sol";
import {SToken} from "./SToken.sol";

contract BoomPool {
    using SafeERC20 for SToken;
    using UserInfoUpdate for DataTypes.UserData;

    address private _admin;
    uint256 private _assertCount;

    mapping(uint256 => address) private _assetList;
    mapping(address => DataTypes.AssetData) private _assetInfo;
    mapping(address => DataTypes.UserData) private _userInfo;

    constructor() {
        _admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Must Be Admin");
        _;
    }

    function deposit(address asset, uint256 amount) public {
        DataTypes.AssetData storage assetData = _assetInfo[asset];
        require(assetData.isActive, "BP__AssertNotActive");
        //Could update assetData state, all kinds of index
        address sTokenAddr = assetData.sTokenAddress;
        SToken(sTokenAddr).safeTransferFrom(msg.sender, sTokenAddr, amount);
        //mint function needed to finish
        bool isFirst = SToken(sTokenAddr).mint(
            msg.sender,
            amount,
            assetData.assetIndex
        );
        if (isFirst) {
            _userInfo[msg.sender].setDepositAssert(assetData.id, true);
        }
    }

    function withdraw() public {}

    function borrow() public {}

    function addAssert(address assertAddr) public onlyAdmin {
        bool isAdded = _assetInfo[assertAddr].id != 0 ||
            _assetList[0] == assertAddr;
        if (!isAdded) {
            _assetList[_assertCount] = assertAddr;
            _assetInfo[assertAddr].id = uint8(_assertCount);
            _assertCount += 1;
        }
    }

    function initAssert(
        address assertAddr,
        uint256 assetIndex,
        address sToken,
        address dToken
    ) public onlyAdmin {
        DataTypes.AssetData storage assetData = _assetInfo[assertAddr];
        assetData.isActive = true;
        assetData.assetIndex = assetIndex;
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
