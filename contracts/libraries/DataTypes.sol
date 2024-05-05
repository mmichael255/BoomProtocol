// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library DataTypes {
    struct AssetData {
        uint8 id;
        bool isActive;
        uint256 assetIndex;
        address sTokenAddress;
        address dTokenAddress;
    }

    struct UserData {
        uint256 data;
    }
}
