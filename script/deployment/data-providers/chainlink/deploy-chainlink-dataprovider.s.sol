// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "src/bridge-providers/mayan/MayanSwap.sol";
import "script/Chains.s.sol";
import "src/data-providers/chainlink/ChainlinkAdapter.sol";

contract DeployChainlinkDataProvider is Script, Chains {
    struct ChainlinkIfaces {
        AggregatorV3Interface ethUsdPricefeed;
        AggregatorV3Interface solUsdPricefeed;
    }

    AggregatorV3Interface[][] internal perNetworkProvider = [
        [
            AggregatorV3Interface(0x24ceA4b8ce57cdA5058b924B9B9987992450590c),
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612)
        ]
    ];

    function run() external {
        require(
            perNetworkProvider.length == CHAINS.length,
            "Networks & Chainlink Providers length mismatch"
        );

        for (uint256 i; i < CHAINS.length; i++) {
            // read env variables and choose EOA for transaction signing
            vm.createSelectFork(CHAINS[i]);

            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

            vm.startBroadcast(deployerPrivateKey);
            ChainlinkAdapter chainlinkAdapter = new ChainlinkAdapter(
                perNetworkProvider[i][0],
                perNetworkProvider[i][1]
            );
            chainlinkAdapter;
            vm.stopBroadcast();
        }
    }
}

// forge script ./script/deployment/data-providers/chainlink/deploy-chainlink-dataprovider.s.sol --verify -vvv --ffi
