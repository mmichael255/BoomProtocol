// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UserInfoUpdate} from "./UserInfoUpdate.sol";
import {DataTypes} from "./DataTypes.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {OracleLib, AggregatorV3Interface} from "./OracleLib.sol";

library Calculate {
    using OracleLib for AggregatorV3Interface;
    using UserInfoUpdate for DataTypes.UserData;

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THREHOLD = 50; //this mean you need to be 200% over-collateralized
    uint256 private constant LIQUIDATION_BONUS = 10;
    uint256 private constant LIQUIDATION_PRECISION = 100;

    function calculateUserData(
        mapping(uint256 => address) storage assetList,
        mapping(address => DataTypes.AssetData) storage assetInfo,
        DataTypes.UserData memory userUsageData,
        address user,
        uint256 assetCount
    ) internal returns (uint256, uint256) {
        uint256 totalCollateralInEth;
        for (uint256 assetId = 0; assetId < assetCount; assetId++) {
            if (!userUsageData.isDepositedAssertOrBorrowing(assetId)) {
                continue;
            }
            address currentAssetAddress = assetList[assetId];
            DataTypes.AssetData storage currentAsset = assetInfo[
                currentAssetAddress
            ];
            address currentAssetPricedFeed = currentAsset.priceFeed;
            if (userUsageData.isDepositedAssert(assetId)) {
                uint256 tokenUnit = 10 ** currentAsset.decimals;
                address currentAssetSToken = currentAsset.sTokenAddress;
                uint256 sTokenBalanceOfUser = IERC20(currentAssetSToken)
                    .balanceOf(user);
            }
        }
    }

    function getAssetValueInEth(address priceFeed) public returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeed);
        (, int256 price, , , ) = priceFeed.checkStaleLatestRoundData();
        return uint256(price);
    }
}
