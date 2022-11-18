// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IKeepERC20 {
    //============ Params ============//

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

    //============ Events ============//

    event SetScheduleFeeRatio(uint256 prev, uint256 curr);
    event SetRecoveryFeeRatio(uint256 prev, uint256 curr);
    event SetFeeTo(address prev, address curr);

    event Wrap(address indexed from, address indexed to, uint256 amount);
    event Unwrap(address indexed from, address indexed to, uint256 amount);

    event CreateWallet(address indexed account, address wallet);

    event CancelTask(address indexed account, uint256 indexed tid);

    event QueueScheduledTransfer(
        uint256 indexed tid,
        address from,
        address to,
        uint256 amount,
        bytes extra,
        uint256 interval
    );
    event ExecuteScheduledTransfer(uint256 indexed tid);

    event QueueRecoverableTransfer(
        uint256 indexed tid,
        address from,
        address to,
        uint256 amount,
        bytes extra,
        uint256 interval
    );
    event ExecuteRecoverableTransfer(uint256 indexed tid);

    event QueueExpirableApprove(
        uint256 indexed tid,
        address owner,
        address spender,
        uint256 amount,
        uint256 interval
    );
    event ExecuteExpirableApprove(uint256 indexed tid);

    //============ Initialize ============//

    function token() external view returns (address);

    function setScheduleFeeRatio(uint256 newScheduleFeeRatio_) external;

    function setRecoveryFeeRatio(uint256 newRecoveryFeeRatio_) external;

    function setFeeTo(address newFeeTo_) external;

    //============ View Functions ============//

    function tasks(uint256 tid) external view returns (Task memory);

    function tasksOf(address account)
        external
        view
        returns (uint256[] memory tids);

    function activeTasksOf(address account)
        external
        view
        returns (uint256[] memory tids);

    function walletOf(address account) external view returns (address);

    //============ Wrap & Unwrap ============//

    function wrap(address to, uint256 amount) external returns (bool);

    function unwrap(address to, uint256 amount) external returns (bool);

    function wrapFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function unwrapFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    //============ Wallet Functions ============//

    function createWallet() external returns (address);

    function revokeWallet() external returns (address);

    function callWallet(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) external returns (bool success, bytes memory returnData);

    //============ KeepERC20 Functions ============//

    function cancel(uint256 tid) external returns (bool);

    //============ KeepERC20 Functions: Scheduled Transfer ============//

    function queueScheduledTransfer(
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool);

    function queueScheduledTransferWithExtra(
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool);

    function queueScheduledTransferFrom(
        address from,
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool);

    function queueScheduledTransferFromWithExtra(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool);

    function executeScheduledTransfer(uint256 tid)
        external
        returns (bytes memory returndata);

    //============ KeepERC20 Functions: Recoverable Transfer ============//

    function queueRecoverableTransfer(
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool);

    function queueRecoverableTransferWithExtra(
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool);

    function queueRecoverableTransferFrom(
        address from,
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool);

    function queueRecoverableTransferFromWithExtra(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool);

    function executeRecoverableTransfer(uint256 tid)
        external
        returns (bytes memory returndata);

    //============ KeepERC20 Functions: Expirable Approve ============//

    function queueExpirableApprove(
        address spender,
        uint256 amount,
        uint256 interval
    ) external returns (uint256 tid);

    function executeExpirableApprove(uint256 tid)
        external
        returns (bytes memory returndata);
}
