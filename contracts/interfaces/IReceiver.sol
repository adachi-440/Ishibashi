// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IReceiver {
    function receiveMessage(
        bytes32 _messageHash,
        uint32 _originChainId,
        address _originSender,
        bytes memory _callData
    ) external;
}
