// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error BP__MustBeAdmin();
    error BP__AssertNotActive();
    error BP__TransationNotAllowed();
    error BoomPoolInsufficientSTokenBlance(
        address user,
        uint256 amount,
        uint256 balance
    );
}
