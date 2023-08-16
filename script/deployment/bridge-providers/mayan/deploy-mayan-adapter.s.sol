// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "src/bridge-providers/mayan/MayanSwap.sol";
import "script/Chains.s.sol";

contract DeployMayanSwapAdapter is Script, Chains {
    function run() external {
        for (uint256 i; i < CHAINS.length; i++) {
            // read env variables and choose EOA for transaction signing
            vm.createSelectFork(CHAINS[i]);

            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

            vm.startBroadcast(deployerPrivateKey);
            MayanSwapAdapter mayan = new MayanSwapAdapter();
            mayan;
            vm.stopBroadcast();
        }
    }
}

// forge script ./script/deployment/bridge-providers/mayan/deploy-mayan-adapter.s.sol --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvv --ffi
