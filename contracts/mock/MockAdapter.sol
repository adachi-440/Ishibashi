// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interfaces/IAdapter.sol";
import "../interfaces/IRouter.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract MockAdapter is IAdapter, Ownable {
    address public router;
    uint256 private nonce;
    mapping(uint32 => address) public supportedNetworks;

    event SendMessage(
        bytes32 messageHash,
        uint32 dstChainId,
        address recipient,
        bytes message
    );

    error UnsupportedNetwork();

    constructor() {
        nonce = 0;
    }

    function sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes calldata _message
    ) external payable {
        address dstAdapter = supportedNetworks[_dstChainId];
        if (dstAdapter == address(0)) revert UnsupportedNetwork();
        bytes memory messageWithRecipient = abi.encode(_message, _recipient);
        _sendMessage(_dstChainId, dstAdapter, messageWithRecipient);
    }

    function receiveMessage(
        uint32 _origin,
        address _sender,
        bytes calldata _body
    ) external {
        (bytes memory message, address recipient) = abi.decode(
            _body,
            (bytes, address)
        );
        IRouter(router).confirmMessage(_origin, _sender, recipient, message);
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
            supportedNetworks[_dstChainIds[i]] = _mailBoxes[i];
        }
    }

    function targetMailBox(uint32 _dstChainId) external view returns (address) {
        return supportedNetworks[_dstChainId];
    }

    function estimateGasFee(
        uint32,
        uint256,
        bytes calldata
    ) external pure returns (uint256) {
        return 100;
    }

    function _sendMessage(
        uint32 _dstChainId,
        address _recipient,
        bytes memory _message
    ) internal {
        bytes32 messageHash = keccak256(
            abi.encodePacked(_dstChainId, _recipient, _message, nonce)
        );
        emit SendMessage(messageHash, _dstChainId, _recipient, _message);
        nonce++;
    }
}
