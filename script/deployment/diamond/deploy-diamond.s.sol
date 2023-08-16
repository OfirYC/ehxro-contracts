// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "src/diamond/Diamond.sol";
import "src/diamond/interfaces/IDiamond.sol";
import "src/diamond/interfaces/IDiamondCut.sol";
import "src/diamond/interfaces/IDiamondLoupe.sol";
import "src/diamond/interfaces/IERC165.sol";
import "src/diamond/interfaces/IERC173.sol";
import "test/diamond/HelperContract.sol";
import "src/diamond/upgradeInitializers/DiamondInit.sol";
import "script/Chains.s.sol";

// ----------------
//   BASE FACETS
// ----------------
import "src/diamond/facets/diamond-base/DiamondCutFacet.sol";
import "src/diamond/facets/diamond-base/DiamondLoupeFacet.sol";
import "src/diamond/facets/diamond-base/OwnershipFacet.sol";

// ----------------
//   CORE FACETS
// ----------------
import "src/diamond/facets/core/Execution.sol";
import "src/diamond/facets/core/StorageManager.sol";

// ----------------
//   BRIDGE FACETS
// ----------------
import "src/diamond/facets/bridge-providers/mayan/StorageManager.sol";

// ----------------
// PAYLOAD ASSEMBLERS
// ----------------
import "src/diamond/facets/payload-assemblers/DexterityTrading.sol";

// ----------------
//     SCRIPT
// ----------------
contract DiamondDeploy is Script, HelperContract, Chains {
    function run() external {
        for (uint256 i; i < CHAINS.length; i++) {
            // read env variables and choose EOA for transaction signing
            vm.createSelectFork(CHAINS[i]);

            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
            address deployerAddress = vm.envAddress("PUBLIC_KEY");

            vm.startBroadcast(deployerPrivateKey);

            // Base
            DiamondCutFacet dCutF = new DiamondCutFacet();
            DiamondLoupeFacet dLoupeF = new DiamondLoupeFacet();
            OwnershipFacet ownerF = new OwnershipFacet();

            // Core
            CoreFacet coreFacet = new CoreFacet();
            StorageManagerFacet storageManagerFacet = new StorageManagerFacet();

            // Bridges
            MayanStorageManagerFacet mayanStorageManagerFacet = new MayanStorageManagerFacet();

            // Payload Assemblers
            DexterityTradingPayloadFacet dexterityTradingPayloadFacet = new DexterityTradingPayloadFacet();

            DiamondInit diamondInit = new DiamondInit();

            // diamod arguments
            DiamondArgs memory _args = DiamondArgs({
                owner: deployerAddress,
                init: address(diamondInit),
                initCalldata: abi.encodeWithSignature("init()")
            });

            // FacetCut array which contains the three standard facets to be added
            FacetCut[] memory cut = new FacetCut[](7);

            cut[0] = FacetCut({
                facetAddress: address(dCutF),
                action: IDiamond.FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondCutFacet")
            });

            cut[1] = (
                FacetCut({
                    facetAddress: address(dLoupeF),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors("DiamondLoupeFacet")
                })
            );

            cut[2] = (
                FacetCut({
                    facetAddress: address(ownerF),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors("OwnershipFacet")
                })
            );

            cut[3] = (
                FacetCut({
                    facetAddress: address(coreFacet),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors("CoreFacet")
                })
            );

            cut[4] = (
                FacetCut({
                    facetAddress: address(storageManagerFacet),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors("StorageManagerFacet")
                })
            );

            cut[5] = (
                FacetCut({
                    facetAddress: address(mayanStorageManagerFacet),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors(
                        "MayanStorageManagerFacet"
                    )
                })
            );

            cut[6] = (
                FacetCut({
                    facetAddress: address(dexterityTradingPayloadFacet),
                    action: FacetCutAction.Add,
                    functionSelectors: generateSelectors(
                        "DexterityTradingPayloadFacet"
                    )
                })
            );

            // deploy diamond
            Diamond diamond = new Diamond(cut, _args);
            diamond;

            vm.stopBroadcast();
        }
    }
}

// forge script ./script/deployment/diamond/deploy-diamond.s.sol --etherscan-api-key $ARBISCAN_API_KEY --broadcast --verify -vvv --ffi
