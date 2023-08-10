// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IRouter.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IReceiver.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Router is IRouter {
    uint256 private _threshold;
    uint256 private _nonce;
    mapping(uint32 => mapping(bytes32 => uint256)) public confirmations;

    event SendMessage(
        bytes32 messageHash,
        uint32 dstChainId,
        address recipient,
        bytes message
    );

    event MessageConfirmed(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message,
        uint256 confirmations
    );

    event MessageDelivered(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message
    );

    event MessageFailed(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message,
        bytes reason
    );

    constructor(uint256 threshold) {
        _threshold = threshold;
        _nonce = 0;
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters
    ) external {
        bytes32 messageHash = keccak256(abi.encodePacked(_message, _nonce));
        bytes memory message = abi.encodePacked(messageHash, _message);
        for (uint256 i = 0; i < _adapters.length; i++) {
            IAdapter adapter = IAdapter(_adapters[i]);
            require(
                adapter.isSupportedNetwork(_dstChainId),
                "Router: unsupported network"
            );
            adapter.sendMessage(_dstChainId, _recipient, message);
        }
        _nonce += 1;
        emit SendMessage(messageHash, _dstChainId, _recipient, _message);
    }

    function confirmMessage(
        uint32 _originChainId,
        address _originSender,
        bytes calldata _message
    ) external {
        (bytes32 messageHash, bytes memory messageBody) = abi.decode(
            _message,
            (bytes32, bytes)
        );
        confirmations[_originChainId][messageHash] += 1;
        if (confirmations[_originChainId][messageHash] < _threshold) {
            emit MessageConfirmed(
                messageHash,
                _originChainId,
                _originSender,
                messageBody,
                confirmations[_originChainId][messageHash]
            );
        }

        if (confirmations[_originChainId][messageHash] == _threshold) {
            try
                IReceiver(_originSender).receiveMessage(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody
                )
            {
                emit MessageConfirmed(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody,
                    confirmations[_originChainId][messageHash]
                );
            } catch Error(string memory reason) {
                emit MessageFailed(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody,
                    bytes(reason)
                );
            }
            emit MessageDelivered(
                messageHash,
                _originChainId,
                _originSender,
                messageBody
            );
        }
    }
}
