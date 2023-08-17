// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IMailbox.sol";
import "./interfaces/IMessageRecipient.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IRouter.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract HyperlaneAdapter is IMessageRecipient, IAdapter, Ownable {
    address public router;
    mapping(uint32 => address) public supportedNetworks;

    error UnsupportedNetwork();

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message
    ) external {
        address mailBox = supportedNetworks[_dstChainId];
        if (mailBox == address(0)) revert UnsupportedNetwork();
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

    function init(
        address _router,
        uint32[] calldata _dstChainIds,
        address[] calldata _mailBoxes
    ) external onlyOwner {
        _setRouter(_router);
        _setSupportedNetwork(_dstChainIds, _mailBoxes);
    }

    function setRouter(address _router) external onlyOwner {
        _setRouter(_router);
    }

    function setSupportedNetwork(
        uint32[] calldata _dstChainIds,
        address[] calldata _mailBoxes
    ) external onlyOwner {
        _setSupportedNetwork(_dstChainIds, _mailBoxes);
    }

    function _setRouter(address _router) private {
        router = _router;
    }

    function _setSupportedNetwork(
        uint32[] calldata _dstChainIds,
        address[] calldata _mailBoxes
    ) private {
        for (uint256 i = 0; i < _dstChainIds.length; i++) {
            uint32 domain = convertChainIdToHyperlaneDomain(_dstChainIds[i]);
            supportedNetworks[domain] = _mailBoxes[i];
        }
    }

    function targetMailBox(uint32 _dstChainId) external view returns (address) {
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
