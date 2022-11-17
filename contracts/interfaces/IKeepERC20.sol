// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IKeepERC20 {
    enum TaskType {
        Schedule,
        Recovery,
        Expire
    }

    struct Task {
        TaskType taskType;
        address sender;
        address receiver;
        uint256 amount;
        bytes extraField;
        bool active;
    }
}
