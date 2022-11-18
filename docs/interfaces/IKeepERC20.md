## `IKeepERC20`






### `token() → address` (external)





### `setScheduleFeeRatio(uint256 newScheduleFeeRatio_)` (external)





### `setRecoveryFeeRatio(uint256 newRecoveryFeeRatio_)` (external)





### `setFeeTo(address newFeeTo_)` (external)





### `tasks(uint256 tid) → struct IKeepERC20.Task` (external)





### `tasksOf(address account) → uint256[] tids` (external)





### `activeTasksOf(address account) → uint256[] tids` (external)





### `walletOf(address account) → address` (external)





### `wrap(address to, uint256 amount) → bool` (external)





### `unwrap(address to, uint256 amount) → bool` (external)





### `wrapFrom(address from, address to, uint256 amount) → bool` (external)





### `unwrapFrom(address from, address to, uint256 amount) → bool` (external)





### `createWallet() → address` (external)





### `revokeWallet() → address` (external)





### `callWallet(address target, uint256 value, string signature, bytes data) → bool success, bytes returnData` (external)





### `cancel(uint256 tid) → bool` (external)





### `queueScheduledTransfer(address to, uint256 amount, uint256 interval) → bool` (external)





### `queueScheduledTransferWithExtra(address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `queueScheduledTransferFrom(address from, address to, uint256 amount, uint256 interval) → bool` (external)





### `queueScheduledTransferFromWithExtra(address from, address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `executeScheduledTransfer(uint256 tid) → bytes returndata` (external)





### `queueRecoverableTransfer(address to, uint256 amount, uint256 interval) → bool` (external)





### `queueRecoverableTransferWithExtra(address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `queueRecoverableTransferFrom(address from, address to, uint256 amount, uint256 interval) → bool` (external)





### `queueRecoverableTransferFromWithExtra(address from, address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `executeRecoverableTransfer(uint256 tid) → bytes returndata` (external)





### `queueExpirableApprove(address spender, uint256 amount, uint256 interval) → uint256 tid` (external)





### `executeExpirableApprove(uint256 tid) → bytes returndata` (external)






### `SetScheduleFeeRatio(uint256 prev, uint256 curr)`





### `SetRecoveryFeeRatio(uint256 prev, uint256 curr)`





### `SetFeeTo(address prev, address curr)`





### `Wrap(address from, address to, uint256 amount)`





### `Unwrap(address from, address to, uint256 amount)`





### `CreateWallet(address account, address wallet)`





### `CancelTask(address account, uint256 tid)`





### `QueueScheduledTransfer(uint256 tid, address from, address to, uint256 amount, bytes extra, uint256 interval)`





### `ExecuteScheduledTransfer(uint256 tid)`





### `QueueRecoverableTransfer(uint256 tid, address from, address to, uint256 amount, bytes extra, uint256 interval)`





### `ExecuteRecoverableTransfer(uint256 tid)`





### `QueueExpirableApprove(uint256 tid, address owner, address spender, uint256 amount, uint256 interval)`





### `ExecuteExpirableApprove(uint256 tid)`





