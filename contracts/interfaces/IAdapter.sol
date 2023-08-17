// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IAdapter {
    function sendMessage(
        uint32 _dstChainID,
        address _recipient,
        bytes calldata _message
    ) external payable;

    function estimateGasFee(
        uint32 _dstChainId,
        uint256 _gasAmount,
        bytes calldata _message
    ) external view returns (uint256);
}
