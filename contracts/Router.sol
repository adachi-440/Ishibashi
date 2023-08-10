// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IRouter.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IReceiver.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Router is IRouter {
    uint256 private _nonce;
    mapping(uint32 => mapping(bytes32 => Comfirmation)) public confirmations;
    struct Comfirmation {
        uint256 confirmations;
        uint256 threshold;
    }

    event SendMessage(
        bytes32 messageHash,
        uint32 dstChainId,
        address recipient,
        bytes message,
        uint256 threshold
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

    constructor() {
        _nonce = 0;
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters,
        uint256 _threshold
    ) external {
        bytes32 messageHash = keccak256(abi.encodePacked(_message, _nonce));
        bytes memory message = abi.encodePacked(messageHash, _message);
        for (uint256 i = 0; i < _adapters.length; i++) {
            IAdapter adapter = IAdapter(_adapters[i]);
            adapter.sendMessage(_dstChainId, _recipient, message);
        }
        confirmations[_dstChainId][messageHash] = Comfirmation(0, _threshold);
        _nonce += 1;
        emit SendMessage(
            messageHash,
            _dstChainId,
            _recipient,
            _message,
            _threshold
        );
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
        Comfirmation storage confirmation = confirmations[_originChainId][
            messageHash
        ];
        confirmation.confirmations += 1;
        if (confirmation.confirmations < confirmation.threshold) {
            emit MessageConfirmed(
                messageHash,
                _originChainId,
                _originSender,
                messageBody,
                confirmation.confirmations
            );
        }

        if (confirmation.confirmations == confirmation.threshold) {
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
                    confirmation.confirmations
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
