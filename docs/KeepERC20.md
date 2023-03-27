## `KeepERC20`



Non-trasnsferable.
Register Chainlink Automation via [https://automation.chain.link/mumbai].

### `onlySender(uint256 tid)`






### `constructor(address owner, address originalToken_, uint256 scheduleFeeRatio_, uint256 recoverFeeRatio_, address feeTo_)` (public)





### `token() → address` (external)





### `setScheduleFeeRatio(uint256 newScheduleFeeRatio_)` (external)





### `setRecoveryFeeRatio(uint256 newRecoveryFeeRatio_)` (external)





### `setFeeTo(address newFeeTo_)` (external)





### `tasks(uint256 tid) → struct IKeepERC20.Task` (external)





### `tasksOf(address account) → uint256[] tids` (external)





### `activeTasksOf(address account) → uint256[] tids` (external)

Returns active tasks only.


Zero means inactive tid.

### `walletOf(address account) → address` (external)





### `wrap(address to, uint256 amount) → bool` (external)





### `unwrap(address to, uint256 amount) → bool` (external)





### `wrapFrom(address from, address to, uint256 amount) → bool` (external)



Owner must approve ERC20 tokens to `address(this)`.

### `unwrapFrom(address from, address to, uint256 amount) → bool` (external)





### `_wrap(address from, address to, uint256 amount)` (internal)





### `_unwrap(address from, address to, uint256 amount)` (internal)





### `createWallet() → address` (external)





### `_createWallet(address account) → address wallet` (internal)





### `revokeWallet() → address` (external)





### `callWallet(address target, uint256 value, string signature, bytes data) → bool success, bytes returnData` (external)





### `cancel(uint256 tid) → bool` (external)





### `queueScheduledTransfer(address to, uint256 amount, uint256 interval) → bool` (external)

Transfers amount to `to` after `interval` blocks.



### `queueScheduledTransferWithExtra(address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)

Transfers amount to `to` after `interval` blocks.



### `queueScheduledTransferFrom(address from, address to, uint256 amount, uint256 interval) → bool` (external)





### `queueScheduledTransferFromWithExtra(address from, address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `executeScheduledTransfer(uint256 tid) → bytes returndata` (external)





### `_queueScheduledTransfer(address from, address to, uint256 amount, bytes extra, uint256 interval) → uint256 tid` (internal)





### `_executeScheduledTransfer(uint256 tid) → bytes returndata` (internal)





### `queueRecoverableTransfer(address to, uint256 amount, uint256 interval) → bool` (external)





### `queueRecoverableTransferWithExtra(address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `queueRecoverableTransferFrom(address from, address to, uint256 amount, uint256 interval) → bool` (external)





### `queueRecoverableTransferFromWithExtra(address from, address to, uint256 amount, bytes extra, uint256 interval) → bool` (external)





### `executeRecoverableTransfer(uint256 tid) → bytes returndata` (external)





### `_queueRecoverableTransfer(address from, address to, uint256 amount, bytes extra, uint256 interval) → uint256 tid` (internal)





### `_executeRecoverableTransfer(uint256 tid) → bytes returndata` (internal)

Receiver also be able to get tokens through `unwrap()` directly.
However, `upwrap()` does not inactive `active`.
In that case, sender still be able to claim `amount` tokens.



### `queueExpirableApprove(address spender, uint256 amount, uint256 interval) → uint256 tid` (external)





### `_queueExpirableApprove(address owner, address spender, uint256 amount, uint256 interval) → uint256 tid` (internal)



Uses `increaseAllowance()` instead of `approve()`.

### `executeExpirableApprove(uint256 tid) → bytes returndata` (external)





### `_executeExpirableApprove(uint256 tid) → bytes returndata` (internal)



Uses `decreaseAllowance()`.

### `pagination(uint256 lowerBound, uint256 upperBound) → bytes` (external)



Pagination for multiple upkeeps.

### `checkUpkeep(bytes checkData) → bool upkeepNeeded, bytes performData` (external)



Uses multiple upkeep for paginated search spaces.
Most of the highest priorities should be placed at front.

### `performUpkeep(bytes performData)` (external)






