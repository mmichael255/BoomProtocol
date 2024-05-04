// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DataTypes {
    struct AssetData {
        uint8 id;
        bool isActive;
        bool isPause;
        address aTokenAddress;
        address dTokenAddress;
    }

    struct UserData {
        uint256 data;
    }
}
