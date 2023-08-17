// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Router.sol";
import "../src/HyperlaneAdapter.sol";

contract DeployScript is Script {
    address payable private owner;

    error NotOwner();

    constructor() {
        owner = payable(msg.sender);
    }

    function run() public {
        if (msg.sender != owner) revert NotOwner();
        vm.startBroadcast();
        Router router = new Router();

        // deploy hypelane adapter
        HyperlaneAdapter adapter = new HyperlaneAdapter();
        adapter.init(router, dstChainIds, mailboxes);

        vm.stopBroadcast();
    }
}
