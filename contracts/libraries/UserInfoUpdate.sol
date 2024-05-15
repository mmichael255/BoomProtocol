// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "./DataTypes.sol";

library UserInfoUpdate {
    function setDepositAssert(
        DataTypes.UserData storage userData,
        uint256 assetId,
        bool toDeposit
    ) internal {
        require(assetId < 128, "Invalid assetId");
        userData.data =
            (userData.data & ~(1 << (assetId * 2 + 1))) |
            (toDeposit ? 1 : 0 << (assetId * 2 + 1));
    }

    function setBorrowAssert(
        DataTypes.UserData storage userData,
        uint256 assetId,
        bool toBorrow
    ) internal {
        require(assetId < 128, "Invalid assetId");
        userData.data =
            (userData.data & ~(1 << (assetId * 2))) |
            (toBorrow ? 1 : 0 << (assetId * 2));
    }

    function isDepositedAssertOrBorrowing(
        DataTypes.UserData memory userData,
        uint256 assetId
    ) internal returns (bool) {
        require(assetId < 128, "Invalid assetId");
        return ((userData.data >> (assetId * 2)) & 3 != 0);
    }
}
