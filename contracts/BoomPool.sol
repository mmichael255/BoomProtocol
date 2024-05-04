// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {DataTypes} from "./libraries/DataTypes.sol";

contract BoomPool {
    mapping(address => DataTypes.AssetData) assetInfo;

    function deposit(address asset, uint256 amount) public {
        DataTypes.AssetData memory assertData = assetInfo[asset];
        require(assertData.isActive, "BP__AssertNotActive");
        require(!assertData.isPause, "BP__AssertPaused");
    }

    function withdraw() public {}

    function borrow() public {}
}
