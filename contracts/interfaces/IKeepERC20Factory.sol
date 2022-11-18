// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IKeepERC20Factory {
    //============ Events ============//

    event SetScheduleFeeRatio(uint256 prev, uint256 curr);
    event SetRecoveryFeeRatio(uint256 prev, uint256 curr);
    event SetFeeTo(address prev, address curr);

    event NewKeepERC20(
        address originalToken,
        uint256 scheduleFeeRatio,
        uint256 recoverFeeRatio,
        address feeTo
    );

    //============ Initialize ============//

    function setScheduleFeeRatio(uint256 newScheduleFeeRatio_) external;

    function setRecoveryFeeRatio(uint256 newRecoveryFeeRatio_) external;

    function setFeeTo(address newFeeTo_) external;

    //============ View Functions ============//

    function keepOf(address token) external view returns (address);

    function keeps(uint256 index) external view returns (address);

    //============ Factory Functions ============//

    function allKeepsLength() external view returns (uint256);

    function createKeep(address token) external returns (address keepToken);
}
