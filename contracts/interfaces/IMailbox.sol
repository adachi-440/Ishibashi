// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IMailbox {
    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) external returns (bytes32);
}
