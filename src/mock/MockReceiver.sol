// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interfaces/IReceiver.sol";

contract MockReceiver is IReceiver {
    event ReceiveMessage(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message
    );

    function receiveMessage(
        bytes32 _messageHash,
        uint32 _originChainId,
        address _originSender,
        bytes memory _callData
    ) external override {
        emit ReceiveMessage(
            _messageHash,
            _originChainId,
            _originSender,
            _callData
        );
    }
}
