// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IMailbox.sol";
import "./interfaces/IMessageRecipient.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IInterchainGasPaymaster.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract HyperlaneAdapter is IMessageRecipient, IAdapter, Ownable {
    address public router;
    IMailbox private mailBox;
    mapping(uint32 => address) public supportedNetworks;

    IInterchainGasPaymaster igp;

    error UnsupportedNetwork();

    constructor(address _mailBox, address _igp) {
        igp = IInterchainGasPaymaster(_igp);
        mailBox = IMailbox(_mailBox);
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message
    ) external payable {
        address dstAdapter = supportedNetworks[_dstChainId];
        if (dstAdapter == address(0)) revert UnsupportedNetwork();
        bytes32 recipient = addressToBytes32(dstAdapter);
        bytes memory messageWithRecipient = abi.encode(_message, _recipient);
        uint32 destinationDomain = convertChainIdToHyperlaneDomain(_dstChainId);
        bytes32 messageId = mailBox.dispatch(
            destinationDomain,
            recipient,
            messageWithRecipient
        );

        igp.payForGas{value: msg.value}(
            messageId, // The ID of the message that was just dispatched
            destinationDomain, // The destination domain of the message
            1000000,
            address(this) // refunds are returned to this contract
        );
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _body
    ) external {
        uint32 origin = convertHyperlaneDomainToChainId(_origin);
        (bytes memory message, address recipient) = abi.decode(
            _body,
            (bytes, address)
        );
        address sender = bytes32ToAddress(_sender);
        IRouter(router).confirmMessage(origin, sender, recipient, message);
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
        address[] calldata _adapters
    ) external onlyOwner {
        _setSupportedNetwork(_dstChainIds, _adapters);
    }

    function _setRouter(address _router) private {
        router = _router;
    }

    function _setSupportedNetwork(
        uint32[] calldata _dstChainIds,
        address[] calldata _adapters
    ) private {
        for (uint256 i = 0; i < _dstChainIds.length; i++) {
            uint32 domain = convertChainIdToHyperlaneDomain(_dstChainIds[i]);
            supportedNetworks[domain] = _adapters[i];
        }
    }

    function targetMailBox(uint32 _dstChainId) external view returns (address) {
        return supportedNetworks[_dstChainId];
    }

    function estimateGasFee(
        uint32 _dstChainId,
        uint256 _gasAmount,
        bytes calldata
    ) public view returns (uint256) {
        uint32 destinationDomain = convertChainIdToHyperlaneDomain(_dstChainId);
        return igp.quoteGasPayment(destinationDomain, _gasAmount);
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
