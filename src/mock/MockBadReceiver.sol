// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interfaces/IReceiver.sol";

contract MockBadReceiver is IReceiver {
    error ReceiveMessageFailed();

    function receiveMessage(bytes32, uint32, address, bytes calldata) external {
        revert ReceiveMessageFailed();
    }
}
