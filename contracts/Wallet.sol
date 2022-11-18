// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IWallet.sol";

contract Wallet is IWallet, Ownable {
    function call(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) external onlyOwner returns (bool success, bytes memory returnData) {
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }

        (success, returnData) = target.call{value: value}(callData);

        emit WalletCall(_msgSender(), target, value, signature, data);
    }

    function revoke() external onlyOwner {
        address msgSender = _msgSender();

        emit RevokeWallet(msgSender, address(this));

        selfdestruct(payable(msgSender));
    }
}
