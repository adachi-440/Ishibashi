// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IRouter.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IReceiver.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract Router is IRouter, Ownable {
    uint256 private _nonce;
    uint256 private _threshold;
    mapping(uint32 => mapping(bytes32 => uint256)) private confirmations;

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

    error InvalidRelayerFee();
    error InsufficientRelayerFee();

    constructor() {
        _nonce = 0;
        _threshold = 1;
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters,
        uint256[] memory _relayerFees
    ) external payable {
        bytes32 messageHash = _generateMessageHash(_message);
        bytes memory message = _getMessage(messageHash, _message);
        if (_adapters.length != _relayerFees.length) {
            revert InvalidRelayerFee();
        }
        uint256 totalFee = msg.value;
        for (uint256 i = 0; i < _adapters.length; i++) {
            if (_relayerFees[i] > totalFee) {
                revert InsufficientRelayerFee();
            }
            IAdapter adapter = IAdapter(_adapters[i]);
            adapter.sendMessage{value: _relayerFees[i]}(
                _dstChainId,
                _recipient,
                message
            );
            totalFee -= _relayerFees[i];
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
        uint256 confirmation = confirmations[_originChainId][messageHash];
        confirmations[_originChainId][messageHash] = confirmation + 1;
        confirmation += 1;
        if (confirmation < _threshold) {
            emit MessageConfirmed(
                messageHash,
                _originChainId,
                _originSender,
                messageBody,
                confirmation
            );
        }
        if (confirmation == _threshold) {
            try
                IReceiver(_originSender).receiveMessage(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody
                )
            {
                emit MessageDelivered(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody
                );
            } catch (bytes memory reason) {
                emit MessageFailed(
                    messageHash,
                    _originChainId,
                    _originSender,
                    messageBody,
                    reason
                );
            }
        }
    }

    function getConfirmation(
        uint32 _dstChainId,
        bytes32 _messageHash
    ) external view returns (uint256) {
        return confirmations[_dstChainId][_messageHash];
    }

    function setThreshold(uint256 _newThreshold) external onlyOwner {
        _threshold = _newThreshold;
    }

    function getThreshold() external view returns (uint256) {
        return _threshold;
    }

    function _generateMessageHash(
        bytes memory _message
    ) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_message, _nonce));
    }

    function _getMessage(
        bytes32 _messageHash,
        bytes calldata _message
    ) internal pure returns (bytes memory) {
        return abi.encode(_messageHash, _message);
    }
}
