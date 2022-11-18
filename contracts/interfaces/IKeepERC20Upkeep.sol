// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IKeepERC20Factory {
    //============ Automation ============//

    function pagination(uint256 lowerBound, uint256 upperBound)
        external
        pure
        returns (bytes memory);

    function checkUpkeep(bytes calldata checkData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
}
