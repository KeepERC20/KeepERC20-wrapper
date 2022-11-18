// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Encoder {
    //============ Pagination ============//

    function encodePagination(uint256 lowerBound, uint256 upperBound)
        external
        pure
        returns (bytes memory data)
    {
        data = abi.encode(lowerBound, upperBound);
    }

    function decodePagination(bytes memory data)
        external
        pure
        returns (uint256 lowerBound, uint256 upperBound)
    {
        (lowerBound, upperBound) = abi.decode(data, (uint256, uint256));
    }

    /// @dev For ids.
    function decodeUint256Array(bytes memory data)
        external
        pure
        returns (uint256[] memory array)
    {
        array = abi.decode(data, (uint256[]));
    }

    //============ Wrap & Unwrap ============//

    function encodeWrapAndUnwrap(address to, uint256 amount)
        external
        pure
        returns (bytes memory data)
    {
        data = abi.encode(to, amount);
    }

    function encodeWrapAndUnwrapFrom(
        address from,
        address to,
        uint256 amount
    ) external pure returns (bytes memory data) {
        data = abi.encode(from, to, amount);
    }

    //============ KeepERC20 Functions ============//

    function encodeCancel(uint256 tid)
        external
        pure
        returns (bytes memory data)
    {
        data = abi.encode(tid);
    }

    function encodeTask(
        address toOrSpender,
        uint256 amount,
        uint256 interval
    ) external pure returns (bytes memory data) {
        data = abi.encode(toOrSpender, amount, interval);
    }

    function encodeTask(
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external pure returns (bytes memory data) {
        data = abi.encode(to, amount, extra, interval);
    }

    function encodeTask(
        address from,
        address to,
        uint256 amount,
        uint256 interval
    ) external pure returns (bytes memory data) {
        data = abi.encode(from, to, amount, interval);
    }

    function encodeTask(
        address from,
        address to,
        uint256 amount,
        bytes memory extra,
        uint256 interval
    ) external pure returns (bytes memory data) {
        data = abi.encode(from, to, amount, extra, interval);
    }
}
