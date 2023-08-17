# 🌉 Ishibashi ⽯橋

## Overview

This project aims to enable more secure execution of cross-chain messaging. It leverages multiple messaging protocols and allows setting k of n thresholds when sending messages. It utilizes multiple messaging protocols to send messages that meet the specified conditions. Upon receiving messages, it waits for k of n messages to be received before executing the messages.

## Architecture

![Architecture](./docs/multi-verification.png)

## Flow

- Secure execution of cross-chain messaging.
- Utilizes multiple messaging protocols.
- Set k of n thresholds when sending messages.
- Utilizes multiple messaging protocols to send messages that meet the specified conditions.
- Waits for k of n messages to be received before executing the messages.

## Benefits

- Reduces the risk of hacking by using multiple messaging protocols with independent verifications.
- Improves the developer experience with a common interface.

## Drawbacks

- Increased gas costs
- Speed is dependent on the slowest messaging protocol

## Installation

```
yarn install
```

## Usage

The following functions are executed in user-defined contracts for message requests.

```solidity
interface IRouter {
    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message,
        address[] calldata _adapters
    ) external;
}


IRouter(router).sendMessage(
    dstChainId, // Destination chain
    receiver, // Contract address to receive the message
    message, // Message in byte format
    adapters // Adapters for the messaging protocol used
);
```

To receive a message, you must define receiveMessage by inheriting IReceiver.

```solidity
interface IReceiver {
    function receiveMessage(
        bytes32 _messageHash,
        uint32 _originChainId,
        address _originSender,
        bytes memory _callData
    ) external;
}

function receiveMessage(
        bytes32 _messageHash,
        uint32 _originChainId,
        address _originSender,
        bytes memory _callData
    ) external override {
        // Arbitrary processing
    }
```

## Contract Address
