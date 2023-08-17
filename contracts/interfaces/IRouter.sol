// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRouter {
    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters
    ) external;

    function confirmMessage(
        uint32 _originChainId,
        address _originSender,
        bytes calldata _message
    ) external;
}
