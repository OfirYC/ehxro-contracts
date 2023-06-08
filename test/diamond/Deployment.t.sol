/**
 * Test deployment of Diamond and facets
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../../src/diamond/Diamond.sol";
import "../../src/diamond/interfaces/IDiamond.sol";
import "../../src/diamond/interfaces/IDiamondCut.sol";
import "../../src/diamond/interfaces/IDiamondLoupe.sol";
import "../../src/diamond/interfaces/IERC165.sol";
import "../../src/diamond/interfaces/IERC173.sol";
import "../../src/diamond/facets/diamond-base/DiamondCutFacet.sol";
import "../../src/diamond/facets/diamond-base/DiamondLoupeFacet.sol";
import "../../src/diamond/facets/diamond-base/OwnershipFacet.sol";
import "../../src/diamond/facets/core/Execution.sol";
import "../../src/diamond/facets/core/StorageManager.sol";
import "./HelperContract.sol";
import "../utils/Forks.t.sol";

contract DiamondTest is Test, HelperContract {
    // ===================
    //      STATES
    // ===================
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    CoreFacet coreFacet;
    StorageManagerFacet storageManagerFacet;

    //interfaces with Facet ABI connected to diamond address
    IDiamondLoupe ILoupe;
    IDiamondCut ICut;

    string[] facetNames;
    address[] facetAddressList;

    /**
     * Setup function
     */
    function setUp() public virtual {
        uint256 networkID = new Forks().ARBITRUM();
        vm.selectFork(networkID);
        deployAndGetDiamond();
    }

    function deployAndGetDiamond() public returns (Diamond) {
        // Core Facets
        dCutFacet = new DiamondCutFacet();
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        coreFacet = new CoreFacet();
        storageManagerFacet = new StorageManagerFacet();

        facetNames = [
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            "OwnershipFacet",
            "CoreFacet",
            "StorageManagerFacet"
        ];

        // diamod arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: address(this),
            init: address(0),
            initCalldata: " "
        });

        // FacetCut with CutFacet for initialisation
        FacetCut[] memory cut0 = new FacetCut[](1);
        cut0[0] = FacetCut({
            facetAddress: address(dCutFacet),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondCutFacet")
        });

        // deploy diamond
        diamond = new Diamond(cut0, _args);

        vm.makePersistent(address(diamond));

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(coreFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("CoreFacet")
            })
        );
        cut[3] = (
            FacetCut({
                facetAddress: address(storageManagerFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("StorageManagerFacet")
            })
        );

        for (uint256 i; i < cut.length; i++)
            vm.makePersistent(cut[i].facetAddress);

        // initialise interfaces
        ILoupe = IDiamondLoupe(address(diamond));
        ICut = IDiamondCut(address(diamond));

        //upgrade diamond
        ICut.diamondCut(cut, address(0), "");

        // get all addresses
        facetAddressList = ILoupe.facetAddresses();

        return diamond;
    }
}
