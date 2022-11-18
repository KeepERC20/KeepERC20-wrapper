// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IKeepERC20.sol";
import "./interfaces/IWallet.sol";
import "./queue/PriorityQueue.sol";
import "./Wallet.sol";

/// @dev Non-trasnsferable.
/// @dev Register Chainlink Automation via [https://automation.chain.link/mumbai].
contract KeepERC20 is
    IKeepERC20,
    PriorityQueue,
    AutomationCompatibleInterface,
    ERC20,
    Ownable
{
    using SafeERC20 for IERC20;

    //============ Params ============//

    IERC20 internal _originalToken;

    uint256 internal constant _DENOMINATOR = 10000;
    uint256 public scheduleFeeRatio;
    uint256 public recoveryFeeRatio;
    address public feeTo;

    mapping(uint256 => Task) internal _tasks;
    mapping(address => uint256[]) internal _tasksOf;
    mapping(address => IWallet) internal _wallets;

    //============ Initialize ============//

    constructor(
        address originalToken_,
        uint256 scheduleFeeRatio_,
        uint256 recoverFeeRatio_,
        address feeTo_
    )
        ERC20(
            string.concat("Keep ", IERC20Metadata(originalToken_).name()),
            string.concat("K", IERC20Metadata(originalToken_).symbol())
        )
    {
        _originalToken = IERC20(originalToken_);
        scheduleFeeRatio = scheduleFeeRatio_;
        recoveryFeeRatio = recoverFeeRatio_;
        feeTo = feeTo_;
    }

    function token() external view returns (address) {
        return address(_originalToken);
    }

    function setScheduleFeeRatio(uint256 newScheduleFeeRatio_)
        external
        onlyOwner
    {
        uint256 prev = scheduleFeeRatio;
        scheduleFeeRatio = newScheduleFeeRatio_;

        emit SetScheduleFeeRatio(prev, scheduleFeeRatio);
    }

    function setRecoveryFeeRatio(uint256 newRecoveryFeeRatio_)
        external
        onlyOwner
    {
        uint256 prev = recoveryFeeRatio;
        recoveryFeeRatio = newRecoveryFeeRatio_;

        emit SetRecoveryFeeRatio(prev, recoveryFeeRatio);
    }

    function setFeeTo(address newFeeTo_) external onlyOwner {
        address prev = feeTo;
        feeTo = newFeeTo_;

        emit SetFeeTo(prev, feeTo);
    }

    //============ Modifiers ============//

    modifier onlySender(uint256 tid) {
        require(
            _msgSender() == _tasks[tid].sender,
            "KeepERC20::onlySender: Only sender."
        );
        _;
    }

    //============ View Functions ============//

    function tasks(uint256 tid) external view returns (Task memory) {
        return _tasks[tid];
    }

    function tasksOf(address account)
        external
        view
        returns (uint256[] memory tids)
    {
        tids = _tasksOf[account];
    }

    /// @notice Returns active tasks only.
    function activeTasksOf(address account)
        external
        view
        returns (uint256[] memory tids)
    {
        uint256[] memory tidsOf = _tasksOf[account];
        uint256 count;
        for (uint256 i = 0; i < tidsOf.length; ) {
            uint256 tid = tidsOf[i];
            if (_tasks[tid].active) {
                tids[count] = tid;
                unchecked {
                    count++;
                }
            }
            unchecked {
                ++i;
            }
        }

        // return
        if (count > 0) {
            // resize memory
            assembly {
                mstore(tids, count)
            }
        }
    }

    function walletOf(address account) external view returns (address) {
        return address(_wallets[account]);
    }

    //============ Wrap & Unwrap ============//

    function wrap(address to, uint256 amount) external returns (bool) {
        _wrap(_msgSender(), to, amount);
        return true;
    }

    function unwrap(address to, uint256 amount) external returns (bool) {
        _unwrap(_msgSender(), to, amount);
        return true;
    }

    /// @dev Owner must approve ERC20 tokens to `address(this)`.
    function wrapFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _wrap(from, to, amount);
        return true;
    }

    function unwrapFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _unwrap(from, to, amount);
        return true;
    }

    function _wrap(
        address from,
        address to,
        uint256 amount
    ) internal {
        _originalToken.safeTransferFrom(from, address(this), amount);
        _mint(to, amount);

        emit Wrap(from, to, amount);
    }

    function _unwrap(
        address from,
        address to,
        uint256 amount
    ) internal {
        _burn(from, amount);
        _originalToken.safeTransfer(to, amount);

        emit Wrap(from, to, amount);
    }

    //============ Wallet Functions ============//

    function createWallet() external returns (address) {
        address msgSender = _msgSender();
        require(
            address(_wallets[msgSender]) == address(0),
            "KeepERC20::createWallet: already exists."
        );
        return _createWallet(msgSender);
    }

    function _createWallet(address account) internal returns (address wallet) {
        _wallets[account] = new Wallet();
        wallet = address(_wallets[account]);

        emit CreateWallet(account, wallet);
    }

    function revokeWallet() external returns (address) {
        address msgSender = _msgSender();
        address wallet = address(_wallets[msgSender]);
        _wallets[msgSender].revoke();
        delete _wallets[msgSender];
        return wallet;
    }

    function callWallet(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) external returns (bool success, bytes memory returnData) {
        address msgSender = _msgSender();
        return _wallets[msgSender].call(target, value, signature, data);
    }

    //============ KeepERC20 Functions ============//

    function cancel(uint256 tid) external onlySender(tid) returns (bool) {
        _tasks[tid].active = false;

        emit CancelTask(_msgSender(), tid);

        return true;
    }

    //============ KeepERC20 Functions: Scheduled Transfer ============//

    /// @notice Transfers amount to `to` after `interval` blocks.
    function queueScheduledTransfer(
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool) {
        _queueScheduledTransfer(_msgSender(), to, amount, "", interval);
        return true;
    }

    /// @notice Transfers amount to `to` after `interval` blocks.
    function queueScheduledTransferWithExtra(
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool) {
        _queueScheduledTransfer(_msgSender(), to, amount, extra, interval);
        return true;
    }

    function queueScheduledTransferFrom(
        address from,
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _queueScheduledTransfer(from, to, amount, "", interval);
        return true;
    }

    function queueScheduledTransferFromWithExtra(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _queueScheduledTransfer(from, to, amount, extra, interval);
        return true;
    }

    function executeScheduledTransfer(uint256 tid)
        external
        returns (bytes memory returndata)
    {
        return _executeScheduledTransfer(tid);
    }

    function _queueScheduledTransfer(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) internal returns (uint256 tid) {
        uint256 atBlock = block.number + interval;

        // fee
        uint256 fee;
        if (scheduleFeeRatio != 0 && feeTo != address(0)) {
            fee = (amount * scheduleFeeRatio) / _DENOMINATOR;
            _originalToken.safeTransferFrom(from, feeTo, fee);
        }

        // wrap
        _wrap(from, from, amount - fee); // send to `to` later.

        // task
        Heap.Node memory node = insert(atBlock);
        tid = node.id;
        _tasks[tid] = Task({
            taskType: TaskType.Schedule,
            sender: from,
            receiver: to,
            amount: amount - fee,
            extraField: extra,
            active: true
        });
        _tasksOf[from].push(tid);

        emit QueueScheduledTransfer(tid, from, to, amount, extra, interval);
    }

    function _executeScheduledTransfer(uint256 tid)
        internal
        returns (bytes memory returndata)
    {
        Heap.Node memory node = extractById(tid);
        require(
            node.priority <= block.number,
            "KeepERC20::_executeScheduledTransfer: Not yet."
        );
        Task memory task = _tasks[tid];
        require(
            task.taskType == TaskType.Schedule,
            "KeepERC20::_executeScheduledTransfer: Type invalid."
        );
        require(
            task.active,
            "KeepERC20::_executeScheduledTransfer: Already executed."
        );

        // unwrap
        _unwrap(task.sender, task.receiver, task.amount);

        // call w/ extra field
        if (task.extraField.length != 0) {
            bool success;
            (success, returndata) = task.receiver.call(task.extraField);
            require(
                success,
                "KeepERC20::_executeScheduledTransfer: Fail to calling."
            );
        }

        // task
        task.active = false;

        emit ExecuteScheduledTransfer(tid);
    }

    //============ KeepERC20 Functions: Recoverable Transfer ============//

    function queueRecoverableTransfer(
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool) {
        _queueRecoverableTransfer(_msgSender(), to, amount, "", interval);
        return true;
    }

    function queueRecoverableTransferWithExtra(
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool) {
        _queueRecoverableTransfer(_msgSender(), to, amount, extra, interval);
        return true;
    }

    function queueRecoverableTransferFrom(
        address from,
        address to,
        uint256 amount,
        uint256 interval
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _queueRecoverableTransfer(from, to, amount, "", interval);
        return true;
    }

    function queueRecoverableTransferFromWithExtra(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _queueRecoverableTransfer(from, to, amount, extra, interval);
        return true;
    }

    function executeRecoverableTransfer(uint256 tid)
        external
        returns (bytes memory returndata)
    {
        return _executeRecoverableTransfer(tid);
    }

    function _queueRecoverableTransfer(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) internal returns (uint256 tid) {
        uint256 atBlock = block.number + interval;

        // fee
        uint256 fee;
        if (recoveryFeeRatio != 0 && feeTo != address(0)) {
            fee = (amount * recoveryFeeRatio) / _DENOMINATOR;
            _originalToken.safeTransferFrom(from, feeTo, fee);
        }

        // wrap
        _wrap(from, to, amount - fee); // send to `to` immediately.

        // task
        Heap.Node memory node = insert(atBlock);
        tid = node.id;
        _tasks[tid] = Task({
            taskType: TaskType.Recovery,
            sender: from,
            receiver: to,
            amount: amount - fee,
            extraField: extra,
            active: true
        });
        _tasksOf[to].push(tid);

        emit QueueRecoverableTransfer(tid, from, to, amount, extra, interval);
    }

    /// @notice Receiver also be able to get tokens through `unwrap()` directly.
    /// However, `upwrap()` does not inactive `active`.
    /// In that case, sender still be able to claim `amount` tokens.
    function _executeRecoverableTransfer(uint256 tid)
        internal
        returns (bytes memory returndata)
    {
        Heap.Node memory node = extractById(tid);
        Task memory task = _tasks[tid];
        require(
            task.taskType == TaskType.Recovery,
            "KeepERC20::_executeRecoverableTransfer: Type invalid."
        );
        require(
            task.active,
            "KeepERC20::_executeRecoverableTransfer: Already executed."
        );

        address msgSender = _msgSender();
        if (msgSender == task.receiver) {
            // unwrap
            _unwrap(msgSender, msgSender, task.amount);

            // call w/ extra field
            if (task.extraField.length != 0) {
                bool success;
                (success, returndata) = task.receiver.call(task.extraField);
                require(
                    success,
                    "KeepERC20::_executeScheduledTransfer: Fail to calling."
                );
            }

            // task
            task.active = false;
        } else if (node.priority <= block.number) {
            // unwrap
            _unwrap(task.receiver, task.sender, task.amount); // recover

            // task
            task.active = false;
        }

        emit ExecuteRecoverableTransfer(tid);
    }

    //============ KeepERC20 Functions: Expirable Approve ============//

    function queueExpirableApprove(
        address spender,
        uint256 amount,
        uint256 interval
    ) external returns (uint256 tid) {
        return _queueExpirableApprove(_msgSender(), spender, amount, interval);
    }

    /// @dev Uses `increaseAllowance()` instead of `approve()`.
    function _queueExpirableApprove(
        address owner,
        address spender,
        uint256 amount,
        uint256 interval
    ) internal returns (uint256 tid) {
        if (address(_wallets[owner]) == address(0)) {
            _createWallet(owner);
        }

        // increase allowance
        IWallet wallet = _wallets[owner];
        (bool success, ) = wallet.call(
            address(_originalToken),
            0,
            "increaseAllowance(address,uint256)",
            abi.encode(spender, amount)
        );
        require(
            success,
            "KeepERC20::_queueExpirableApprove: Fail to `call` wallet."
        );

        uint256 atBlock = block.number + interval; // expire at

        // task
        Heap.Node memory node = insert(atBlock);
        tid = node.id;
        _tasks[tid] = Task({
            taskType: TaskType.Expire,
            sender: owner, // _wallets[owner]
            receiver: spender,
            amount: amount,
            extraField: "",
            active: true
        });
        _tasksOf[owner].push(tid);

        emit QueueExpirableApprove(tid, owner, spender, amount, interval);
    }

    function executeExpirableApprove(uint256 tid)
        external
        returns (bytes memory returndata)
    {
        return _executeExpirableApprove(tid);
    }

    /// @dev Uses `decreaseAllowance()`.
    function _executeExpirableApprove(uint256 tid)
        internal
        returns (bytes memory returndata)
    {
        Heap.Node memory node = extractById(tid);
        require(
            node.priority <= block.number,
            "KeepERC20::_executeExpirableApprove: Not yet."
        );
        Task memory task = _tasks[tid];
        require(
            task.taskType == TaskType.Expire,
            "KeepERC20::_executeExpirableApprove: Type invalid."
        );
        require(
            task.active,
            "KeepERC20::_executeExpirableApprove: Already executed."
        );

        // decrease allowance
        IWallet wallet = _wallets[task.sender];
        bool success;
        (success, returndata) = wallet.call(
            address(_originalToken),
            0,
            "decreaseAllowance(address,uint256)",
            abi.encode(task.receiver, task.amount)
        );
        require(
            success,
            "KeepERC20::_executeExpirableApprove: Fail to `call` wallet."
        );

        // task
        task.active = false;

        emit ExecuteExpirableApprove(tid);
    }

    //============ Automation ============//

    // Example: 0-to-10:
    // 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a
    /// @dev Pagination for multiple upkeeps.
    function pagination(uint256 lowerBound, uint256 upperBound)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(lowerBound, upperBound); // [lowerBound, upperBound)
    }

    /// @param checkData paginates [lowerBound, upperBound).
    /// @return upkeepNeeded indicates whether action is needed or not.
    /// @return performData saves tids which are need to be performed.
    /// @dev Uses multiple upkeep for paginated search spaces.
    /// @dev Most of the highest priorities should be placed at front.
    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        Heap.Node[] memory dumps = dump();

        (uint256 lowerBound, uint256 upperBound) = abi.decode(
            checkData,
            (uint256, uint256)
        );
        lowerBound = max(lowerBound, 1);
        upperBound = min(upperBound, dumps.length);

        uint256 count;
        uint256[] memory tids = new uint256[](upperBound - lowerBound);
        uint256 blockNumber = block.number;

        // TODO: approve check
        // check
        for (uint256 i = lowerBound; i < upperBound; ) {
            if (dumps[i].priority <= blockNumber) {
                tids[count] = dumps[i].id;
                unchecked {
                    count++;
                }
            }
            unchecked {
                ++i;
            }
        }

        // return
        if (count > 0) {
            // resize memory
            assembly {
                mstore(tids, count)
            }
            upkeepNeeded = true;
            performData = abi.encode(tids);
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        uint256[] memory tids = abi.decode(performData, (uint256[]));

        for (uint256 i = 0; i < tids.length; ) {
            uint256 tid = tids[i];

            // TODO: try
            if (_tasks[tid].taskType == TaskType.Schedule) {
                _executeScheduledTransfer(tid); // additional check inside
            } else if (_tasks[tid].taskType == TaskType.Recovery) {
                _executeRecoverableTransfer(tid); // additional check inside
            } else if (_tasks[tid].taskType == TaskType.Expire) {
                _executeExpirableApprove(tid); // additional check inside
            } else {
                revert("KeepERC20::performUpkeep: Never happen.");
            }

            unchecked {
                ++i;
            }
        }
    }
}

function min(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? b : a;
}

function max(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? a : b;
}
