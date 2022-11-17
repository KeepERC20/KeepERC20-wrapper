// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./Heap.sol";

/**
 * Implementation for Solidity v0.8.
 *
 * @notice This is a simple contract that uses the heap library.
 *
 * References:
 *
 * - https://github.com/zmitton/eth-heap
 */
contract PriorityQueue {
    using Heap for Heap.Data;
    Heap.Data public data;

    constructor() {
        data.init();
    }

    function heapify(uint256[] memory priorities) public {
        for (uint256 i; i < priorities.length; i++) {
            data.insert(priorities[i]);
        }
    }

    function insert(uint256 priority) public returns (Heap.Node memory) {
        return data.insert(priority);
    }

    function extractMax() public returns (Heap.Node memory) {
        return data.extractMax();
    }

    function extractById(uint256 id) public returns (Heap.Node memory) {
        return data.extractById(id);
    }

    /* view */
    function dump() public view returns (Heap.Node[] memory) {
        return data.dump();
    }

    function getMax() public view returns (Heap.Node memory) {
        return data.getMax();
    }

    function getById(uint256 id) public view returns (Heap.Node memory) {
        return data.getById(id);
    }

    function getByIndex(uint256 i) public view returns (Heap.Node memory) {
        return data.getByIndex(i);
    }

    function size() public view returns (uint256) {
        return data.size();
    }

    function idCount() public view returns (uint256) {
        return data.idCount;
    }

    function indices(uint256 id) public view returns (uint256) {
        return data.indices[id];
    }
}
