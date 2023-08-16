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
contract DiamondCut is Script, HelperContract, Chains {
    Diamond diamond =
        Diamond(payable(0x4B2A962eDdf1a3aF48Aa8648621e9Fb7670809c8));

    function run() external {
        for (uint256 i; i < CHAINS.length; i++) {
            // read env variables and choose EOA for transaction signing
            vm.createSelectFork(CHAINS[i]);

            uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

            vm.startBroadcast(deployerPrivateKey);

            // Base
            // DiamondCutFacet dCutF = new DiamondCutFacet();
            // DiamondLoupeFacet dLoupeF = new DiamondLoupeFacet();
            // OwnershipFacet ownerF = new OwnershipFacet();

            // Core
            // CoreFacet coreFacet = new CoreFacet();
            StorageManagerFacet storageManagerFacet = new StorageManagerFacet();

            // Bridges
            // MayanStorageManagerFacet mayanStorageManagerFacet = new MayanStorageManagerFacet();

            // Payload Assemblers
            // DexterityTradingPayloadFacet dexterityTradingPayloadFacet = new DexterityTradingPayloadFacet();

            FacetCut[] memory cut = new FacetCut[](1);

            bytes4[] memory sels = new bytes4[](2);
            sels[0] = 0x82891df5;
            sels[1] = 0x8f4d32aa;

            cut[0] = FacetCut({
                facetAddress: address(storageManagerFacet),
                action: FacetCutAction.Add,
                functionSelectors: sels
            });

            DiamondCutFacet(address(diamond)).diamondCut(
                cut,
                address(0),
                hex"00"
            );

            vm.stopBroadcast();
        }
    }
}
// forge script ./script/deployment/diamond/cut-diamond.s.sol --broadcast --verify -vvv --ffi
