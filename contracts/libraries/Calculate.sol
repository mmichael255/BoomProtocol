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
    uint256 private constant MIN_HEALTH_FACTOR = 1;
    uint256 private constant LIQUIDATION_PRECISION = 100;

    function isHealthFactorOkToDecrease(
        address assetAddr,
        mapping(uint256 => address) storage assetList,
        mapping(address => DataTypes.AssetData) storage assetInfo,
        DataTypes.UserData memory userUsageData,
        address user,
        uint256 assetCount,
        uint256 amount
    ) internal returns (bool) {
        DataTypes.AssetData memory assetData = assetInfo[assetAddr];
        (
            uint256 totalCollateralInEth,
            uint256 totalDebtInEth
        ) = calculateUserData(
                assetList,
                assetInfo,
                userUsageData,
                user,
                assetCount
            );
        uint256 assetPrice = getAssetValueInEth(assetData.priceFeed);
        uint256 decreaseValueInEth = (amount / (10 ** assetData.decimals)) *
            assetPrice;
        uint256 totalCollateralAfterDecreaseInEth = totalCollateralInEth -
            decreaseValueInEth;
        uint256 healthFactor = calculateUserHealthFactor(
            totalCollateralAfterDecreaseInEth,
            totalDebtInEth
        );
        return healthFactor < MIN_HEALTH_FACTOR;
    }

    function calculateUserData(
        mapping(uint256 => address) storage assetList,
        mapping(address => DataTypes.AssetData) storage assetInfo,
        DataTypes.UserData memory userUsageData,
        address user,
        uint256 assetCount
    )
        internal
        view
        returns (uint256 totalCollateralInEth, uint256 totalDebtInEth)
    {
        for (uint256 assetId = 0; assetId < assetCount; assetId++) {
            if (!userUsageData.isDepositedAssertOrBorrowing(assetId)) {
                continue;
            }
            address currentAssetAddress = assetList[assetId];
            DataTypes.AssetData storage currentAsset = assetInfo[
                currentAssetAddress
            ];
            address currentAssetPriceFeedAddr = currentAsset.priceFeed;
            uint256 currentAssetUintPriceInEth = getAssetValueInEth(
                currentAssetPriceFeedAddr
            );
            uint256 tokenUnit = 10 ** currentAsset.decimals;

            if (userUsageData.isDepositedAssert(assetId)) {
                address currentAssetSToken = currentAsset.sTokenAddress;
                uint256 sTokenBalanceOfUser = IERC20(currentAssetSToken)
                    .balanceOf(user);
                uint256 userCurrentAssetBalanceInEth = (sTokenBalanceOfUser /
                    tokenUnit) * currentAssetUintPriceInEth;
                totalCollateralInEth += userCurrentAssetBalanceInEth;
            }
            //calculate debt
            if (userUsageData.isBorrowing(assetId)) {
                address currentAssetDToken = currentAsset.dTokenAddress;
                uint256 dTokenBalanceOfUser = IERC20(currentAssetDToken)
                    .balanceOf(user);
                uint256 userCurrentAssetDebtInEth = (dTokenBalanceOfUser /
                    tokenUnit) * currentAssetUintPriceInEth;
                totalDebtInEth += userCurrentAssetDebtInEth;
            }
        }
    }

    function calculateUserHealthFactor(
        uint256 collateralInEth,
        uint256 debtInEth
    ) internal returns (uint256) {
        //if debt is 0 ?
        if (debtInEth == 0) {
            return 1e18;
        }
        uint256 totalCollateralAdjustForThrehold = (collateralInEth *
            LIQUIDATION_THREHOLD) / LIQUIDATION_PRECISION;
        return (totalCollateralAdjustForThrehold / debtInEth);
    }

    function getAssetValueInEth(
        address priceFeedAddr
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddr);
        (, int256 price, , , ) = priceFeed.checkStaleLatestRoundData();
        return uint256(price);
    }
}
