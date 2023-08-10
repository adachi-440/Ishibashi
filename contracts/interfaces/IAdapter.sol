// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IAdapter {
    function sendMessage(
        uint32 _dstChainID,
        address _recipient,
        bytes calldata _message
    ) external;

    function isSupportedNetwork(
        uint32 _dstchainId
    ) external view returns (bool);
}
