// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IKeepERC20Factory.sol";
import "./KeepERC20.sol";

contract KeepERC20Factory is IKeepERC20Factory, Ownable {
    //============ Params ============//

    mapping(address => address) internal _keepOf;
    address[] internal _keeps;

    // uint256 internal constant _DENOMINATOR = 10000;
    uint256 public scheduleFeeRatio;
    uint256 public recoveryFeeRatio;
    address public feeTo;

    //============ Initialize ============//

    constructor(
        uint256 scheduleFeeRatio_,
        uint256 recoverFeeRatio_,
        address feeTo_
    ) {
        scheduleFeeRatio = scheduleFeeRatio_;
        recoveryFeeRatio = recoverFeeRatio_;
        feeTo = feeTo_;

        emit SetScheduleFeeRatio(0, scheduleFeeRatio);
        emit SetRecoveryFeeRatio(0, recoveryFeeRatio);
        emit SetFeeTo(address(0), feeTo);
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

    //============ View Functions ============//

    function keepOf(address token) external view returns (address) {
        return _keepOf[token];
    }

    function keeps(uint256 index) external view returns (address) {
        return _keeps[index];
    }

    //============ Factory Functions ============//

    function allKeepsLength() external view returns (uint256) {
        return _keeps.length;
    }

    function createKeep(address token) external returns (address keepToken) {
        require(
            token != address(0),
            "KeepERC20Factory::createKeep: ZERO_ADDRESS"
        );
        require(
            _keepOf[token] == address(0),
            "KeepERC20Factory::createKeep: KEEP_EXISTS"
        );

        KeepERC20 keepTokenContract = new KeepERC20{
            salt: keccak256(abi.encodePacked(token))
        }(owner(), token, scheduleFeeRatio, recoveryFeeRatio, feeTo);
        keepToken = address(keepTokenContract);

        _keepOf[token] = keepToken;
        _keeps.push(keepToken);

        emit NewKeepERC20(token, scheduleFeeRatio, recoveryFeeRatio, feeTo);
    }
}
