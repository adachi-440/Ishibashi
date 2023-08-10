// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IMailbox.sol";
import "./interfaces/IMessageRecipient.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IRouter.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract HyperlaneAdapter is IMessageRecipient, IAdapter, Ownable {
    address public mailBox;
    address public router;
    mapping(uint32 => bool) public supportedNetworks;

    constructor(address _mailBox) {
        mailBox = _mailBox;
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message
    ) external {
        bytes32 recipient = addressToBytes32(_recipient);
        uint32 destinationDomain = convertChainIdToHyperlaneDomain(_dstChainId);
        IMailbox(mailBox).dispatch(destinationDomain, recipient, _message);
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _body
    ) external {
        uint32 origin = convertHyperlaneDomainToChainId(_origin);
        address sender = bytes32ToAddress(_sender);
        IRouter(router).confirmMessage(origin, sender, _body);
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    function setRouter(address _router) external {
        router = _router;
    }

    function setSupportedNetwork(
        uint32[] calldata _dstChainIds
    ) external onlyOwner {
        for (uint256 i = 0; i < _dstChainIds.length; i++) {
            supportedNetworks[_dstChainIds[i]] = true;
        }
    }

    function isSupportedNetwork(
        uint32 _dstChainId
    ) external view returns (bool) {
        return supportedNetworks[_dstChainId];
    }

    function convertChainIdToHyperlaneDomain(
        uint32 _dstChainId
    ) internal pure returns (uint32) {
        if (_dstChainId == 1287) {
            return 0x6d6f2d61;
        } else {
            return _dstChainId;
        }
    }

    function convertHyperlaneDomainToChainId(
        uint32 _domain
    ) internal pure returns (uint32) {
        if (_domain == 0x6d6f2d61) {
            return 1287;
        } else {
            return _domain;
        }
    }
}
