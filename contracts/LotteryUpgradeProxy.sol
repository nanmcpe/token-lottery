// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./proxy/TransparentUpgradeableProxy.sol";

contract LotteryUpgradeProxy is TransparentUpgradeableProxy {
    constructor(
        address logic,
        address admin,
        bytes memory data
    ) public TransparentUpgradeableProxy(logic, admin, data) {}
}
