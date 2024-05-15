// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UserInfoUpdate} from "./UserInfoUpdate.sol";
import {DataTypes} from "./DataTypes.sol";
import {OracleLib, AggregatorV3Interface} from "./OracleLib.sol";

library Calculate {
    using OracleLib for AggregatorV3Interface;
    using UserInfoUpdate for DataTypes.UserData;

    function calculateUserData(
        mapping(uint256 => address) storage assetList,
        mapping(address => DataTypes.AssetData) storage assetInfo,
        DataTypes.UserData memory userUsageData,
        uint256 assetCount
    ) internal returns (uint256, uint256) {
        for (uint256 i = 0; i < assetCount; i++) {
            if (!userUsageData.isDepositedAssertOrBorrowing(i)) {
                continue;
            }
            address currentAssetAddress = assetList[i];
            DataTypes.AssetData storage currentAsset = assetInfo[
                currentAssetAddress
            ];
            address currentAssetPricedFeed = currentAsset.priceFeed;
        }
    }
}
