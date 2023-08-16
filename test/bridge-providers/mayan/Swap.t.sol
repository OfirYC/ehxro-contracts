// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./Storage.t.sol";

contract MayanSwapAdapterTest is MayanTestContract {
    // ==========
    //   SETUP
    // ==========
    function setUp() public virtual override {
        super.setUp();
    }

    // ==========
    //   TESTS
    // ==========
    /**
     * Test swapping not working due to us not being a diamond deleagte calling
     */
    function testAdapterCannotBeDirectlyCalled() external {
        vm.expectRevert();
        mayanSwapAdapter.bridgeHxroPayloadWithTokens(
            SOL_USDC,
            10 * 10 ** 18,
            address(this),
            abi.encode("Random Payload")
        );
    }

    /**
     * Test swap working through HXRO diamond
     */
    function testMayanSwapSwapping() external {
        uint256 swapAmount = 10 * 10 ** 7;
        uint256 privKey = 412421421;
        vm.txGasPrice(1);
        // Dont wanna get fees > amt err
        vm.assume(swapAmount > 1 * 10 ** 7);

        uint256 swapAmt = uint256(swapAmount);

        _validateFuzzedKey(privKey);

        address signer = vm.addr(privKey);

        uint256 startingNonce = 0;

        bytes memory payload = bytes.concat(
            hex"1111111111111111111111111111111111111111111111111111111111111111",
            abi.encode(startingNonce)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, keccak256(payload));

        assertEq(
            signer,
            ecrecover(keccak256(payload), v, r, s),
            "[MayanSwapAdapterTest]: Signed Payload Signer Mismatch"
        );

        // WE do not have any tokens.
        vm.expectRevert();
        CoreFacet(address(diamond)).executeHxroPayloadWithTokens(
            InboundPayload({
                solToken: SOL_USDC,
                amount: swapAmt,
                messageHash: payload
            }),
            abi.encodePacked(r, s, v)
        );

        deal(address(USDC), signer, swapAmt);

        assertEq(
            IERC20(USDC).balanceOf(signer),
            swapAmt,
            "[MayanSwapAdapterTest]: USDC deal() failed - No balance"
        );

        vm.prank(signer);
        USDC.approve(address(diamond), type(uint256).max);
        vm.prank(signer);
        BridgeResult memory bridgeRes = CoreFacet(address(diamond))
            .executeHxroPayloadWithTokens(
                InboundPayload({
                    solToken: SOL_USDC,
                    amount: swapAmt,
                    messageHash: payload
                }),
                abi.encodePacked(r, s, v)
            );
        assertEq(
            uint256(bridgeRes.id),
            uint256(Bridge.MAYAN_SWAP),
            "[MayanSwapAdapterTest]: Bridged, but bridge provider ID mismatches"
        );

        assertEq(
            IERC20(USDC).balanceOf(signer),
            0,
            "[MayanSwapAdapterTest]: Bridged, but no USDC was deducted by bridge"
        );

        assertEq(
            abi.decode(bridgeRes.trackableHash, (uint256)),
            0,
            "[MayanSwapAdapterTest]: Bridged for first time, but wormhole sequence is not 0"
        );

        // We want to see wormhole seq incremented
        deal(address(USDC), signer, swapAmt);

        assertEq(
            IERC20(USDC).balanceOf(signer),
            swapAmt,
            "[MayanSwapAdapterTest]: USDC deal() failed - No balance"
        );

        payload = bytes.concat(
            hex"1111111111111111111111111111111111111111111111111111111111111111",
            abi.encode(startingNonce + 1)
        );

        (v, r, s) = vm.sign(privKey, keccak256(payload));

        vm.prank(signer);
        bridgeRes = CoreFacet(address(diamond)).executeHxroPayloadWithTokens(
            InboundPayload({
                solToken: SOL_USDC,
                amount: swapAmt,
                messageHash: payload
            }),
            abi.encodePacked(r, s, v)
        );

        assertEq(
            abi.decode(bridgeRes.trackableHash, (uint256)),
            1,
            "[MayanSwapAdapterTest]: Bridged for second time, but wormhole sequence is not 1"
        );
    }

    function _validateFuzzedKey(uint256 key) internal view {
        vm.assume(key > 10 && key < MAX_PRIV_KEY);
    }
}
