// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ITestERC20 {
    function mint(address account, uint256 amount) external;
}
