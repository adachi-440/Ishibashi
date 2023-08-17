// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Router.sol";
import "../src/mock/MockAdapter.sol";
import "../src/mock/MockReceiver.sol";
import "../src/mock/MockBadReceiver.sol";

contract RouterTest is Test {
    Router public router;
    MockAdapter public adapter1;
    MockAdapter public adapter2;
    MockReceiver public receiver;
    MockBadReceiver public badReceiver;

    uint32[] dstChainIds = [1, 2];
    address[] supportedNetworks;
    uint256 nonce = 0;
    bytes message = bytes("hello world");

    event SendMessage(
        bytes32 messageHash,
        uint32 dstChainId,
        address recipient,
        bytes message
    );

    event ReceiveMessage(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message
    );

    event MessageConfirmed(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message,
        uint256 confirmations
    );

    event MessageFailed(
        bytes32 messageHash,
        uint32 originChainId,
        address originSender,
        bytes message,
        bytes reason
    );

    function setUp() public {
        router = new Router();
        adapter1 = new MockAdapter();
        adapter2 = new MockAdapter();
        receiver = new MockReceiver();
        badReceiver = new MockBadReceiver();

        supportedNetworks.push(address(adapter1));
        supportedNetworks.push(address(adapter2));

        adapter1.init(address(router), dstChainIds, supportedNetworks);
        adapter2.init(address(router), dstChainIds, supportedNetworks);
    }

    function test_UnsupportedNetwork() public {
        uint32 dstChainId = 3;
        vm.expectRevert(bytes4(keccak256("UnsupportedNetwork()")));
        router.sendMessage(
            dstChainId,
            address(receiver),
            message,
            supportedNetworks
        );
    }

    function test_SendMessage() public {
        bytes32 messageHash = keccak256(abi.encodePacked(message, nonce));
        uint32 dstChainId = 1;
        vm.expectEmit();
        emit SendMessage(messageHash, dstChainId, address(receiver), message);
        router.sendMessage(
            dstChainId,
            address(receiver),
            message,
            supportedNetworks
        );
        nonce++;
    }

    function test_ReceiveMessage() public {
        // send message
        bytes32 messageHash = keccak256(abi.encodePacked(message, nonce));
        bytes memory body = abi.encode(messageHash, message);
        uint32 dstChainId = 1;
        router.sendMessage(
            dstChainId,
            address(receiver),
            message,
            supportedNetworks
        );
        nonce++;

        // confirm message in Adaper 1
        vm.expectEmit();
        emit ReceiveMessage(
            messageHash,
            dstChainId,
            address(receiver),
            message
        );

        adapter1.receiveMessage(dstChainId, address(receiver), body);
    }

    function test_ConfirmMessage() public {
        // set threshold
        router.setThreshold(2);
        // send message
        bytes32 messageHash = keccak256(abi.encodePacked(message, nonce));
        bytes memory body = abi.encode(messageHash, message);
        uint32 dstChainId = 1;
        router.sendMessage(
            dstChainId,
            address(receiver),
            message,
            supportedNetworks
        );
        nonce++;

        // confirm message in Adaper 1
        vm.expectEmit();
        emit MessageConfirmed(
            messageHash,
            dstChainId,
            address(receiver),
            message,
            1
        );

        adapter1.receiveMessage(dstChainId, address(receiver), body);
        uint256 confirmation = router.getConfirmation(dstChainId, messageHash);
        assertEq(confirmation, 1);
    }

    function test_ReceiverError() public {
        // set threshold
        router.setThreshold(1);
        // send message
        bytes32 messageHash = keccak256(abi.encodePacked(message, nonce));
        bytes memory body = abi.encode(messageHash, message);
        uint32 dstChainId = 1;
        router.sendMessage(
            dstChainId,
            address(badReceiver),
            message,
            supportedNetworks
        );
        nonce++;

        // confirm message in Adaper 1
        vm.expectEmit();
        emit MessageFailed(
            messageHash,
            dstChainId,
            address(badReceiver),
            message,
            abi.encodePacked(bytes4(keccak256("ReceiveMessageFailed()")))
        );

        adapter1.receiveMessage(dstChainId, address(badReceiver), body);
        uint256 confirmation = router.getConfirmation(dstChainId, messageHash);
        assertEq(confirmation, 1);
    }
}
