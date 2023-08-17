// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Router.sol";
import "../src/mock/MockAdapter.sol";

contract RouterTest is Test {
    Router public router;
    MockAdapter public adapter1;
    MockAdapter public adapter2;

    uint32[] dstChainIds = [1, 2];
    address[] supportedNetworks;
    uint256 nonce = 0;

    event SendMessage(
        bytes32 messageHash,
        uint32 dstChainId,
        address recipient,
        bytes message,
        uint256 threshold
    );

    function setUp() public {
        router = new Router();
        adapter1 = new MockAdapter();
        adapter2 = new MockAdapter();
        supportedNetworks.push(address(adapter1));
        supportedNetworks.push(address(adapter2));

        adapter1.init(address(router), dstChainIds, supportedNetworks);
        adapter2.init(address(router), dstChainIds, supportedNetworks);
    }

    function test_sendMessage() public {
        bytes memory message = abi.encodePacked("hello world");
        bytes32 messageHash = keccak256(abi.encodePacked(message, nonce));
        uint32 dstChainId = 1;
        uint256 thresholdNumber = 1;
        vm.expectEmit();
        emit SendMessage(
            messageHash,
            dstChainId,
            address(adapter1),
            message,
            thresholdNumber
        );
        router.sendMessage(
            dstChainId,
            address(adapter1),
            message,
            supportedNetworks,
            thresholdNumber
        );
        (uint256 confirmations, uint256 threshold) = router.getConfirmation(
            dstChainId,
            messageHash
        );

        assertEq(confirmations, 0);
        assertEq(threshold, thresholdNumber);
    }
}
