// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IWallet {
    event WalletCall(
        address indexed owner,
        address target,
        uint256 value,
        string signature,
        bytes data
    );
    event RevokeWallet(address indexed account, address wallet);

    function call(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) external returns (bool success, bytes memory returnData);

    function revoke() external;
}
