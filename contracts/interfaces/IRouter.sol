// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRouter {
    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters,
        uint256[] calldata _relayerFees
    ) external payable;

    function confirmMessage(
        uint32 _originChainId,
        address _originSender,
        bytes calldata _message
    ) external;

    function estimateGasFees(
        uint32 _dstChainId,
        uint256 _gasAmount,
        bytes calldata _message,
        address[] calldata _adapters
    ) external view returns (uint256[] memory);
}
