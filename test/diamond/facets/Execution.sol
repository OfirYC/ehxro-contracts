/**
 * Testing the execution facet (with a dummy bridge provider)
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../Deployment.t.sol";
import "../../../src/diamond/facets/core/StorageManager.sol";
import "../../../src/diamond/facets/core/Execution.sol";
import "../../../src/FakeBridge.sol";

contract ExecutionTest is DiamondTest {
    IERC20 TOKEN_TO_TEST_WITH =
        IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    bytes32 SOL_TEST_TOKEN =
        0xffffffffffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeeeeeeeeeee;

    ITokenBridge veryRealBridgeProvider;

    uint256 SOLANA_CHAIN_ID = 501484;
    bytes32 HXRO_SOLANA_PROGRAM =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 MAX_PRIV_KEY =
        115792089237316195423570985008687907852837564279074904382605163141518161494337;

    // ==================
    //    CONSTRUCTOR
    // ==================
    function setUp() public virtual override {
        super.setUp();
        // Classify mock bridge provider
        veryRealBridgeProvider = new VeryRealBridgeProvider(address(diamond));
        StorageManagerFacet(address(diamond)).addToken(
            address(TOKEN_TO_TEST_WITH),
            SOL_TEST_TOKEN,
            veryRealBridgeProvider
        );

        StorageManagerFacet(address(diamond)).addToken(
            address(0),
            bytes32(0),
            veryRealBridgeProvider
        );

        StorageManagerFacet(address(diamond)).setPayloadBridgeProvider(
            IPayloadBridge(address(veryRealBridgeProvider))
        );

        StorageManagerFacet(address(diamond)).setHxroSolanaProgram(
            HXRO_SOLANA_PROGRAM
        );
    }

    // ===============
    //    TESTS
    // ===============

    /**
     * Test the plain execution of a HXRO payload
     * @param privKey - The private key of hte signer to use (fuzz input)
     */
    function testPlainExecution(uint256 privKey) public {
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
            "Execution Test: Signer Is Invalid In ECDSA recovery"
        );

        // We are not the signer
        vm.expectRevert();
        CoreFacet(address(diamond)).executeHxroPayload(
            payload,
            abi.encodePacked(r, s, v)
        );

        bytes memory expectedPayload = bytes.concat(
            payload,
            abi.encodePacked(r, s, v)
        );

        vm.startPrank(signer);
        vm.expectEmit(true, true, true, true);

        emit CrosschainPayloadTransfer(
            SOLANA_CHAIN_ID,
            HXRO_SOLANA_PROGRAM,
            expectedPayload
        );

        CoreFacet(address(diamond)).executeHxroPayload(
           payload,
            abi.encodePacked(r, s, v)
        );
    }

    /**
     * Test execution of a HXRO payload WITH tokens bridged,
     * on a mock bridge provider
     * @param privKey - Fuzzed
     * @param tokenAmount - Fuzzed
     */
    function testExecutionWithTokens(
        uint256 privKey,
        uint256 tokenAmount
    ) public {
        _validateFuzzedKey(privKey);
        vm.assume(tokenAmount > 0);

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
            "Execution Test: Signer Is Invalid In ECDSA recovery"
        );

        // We are not the signer
        vm.expectRevert();
        CoreFacet(address(diamond)).executeHxroPayloadWithTokens(
            InboundPayload(SOL_TEST_TOKEN, tokenAmount, payload),
            abi.encodePacked(r, s, v)
        );

        vm.startPrank(signer);

        // We do not have enough tokens
        vm.expectRevert();


        CoreFacet(address(diamond)).executeHxroPayloadWithTokens(
            InboundPayload(SOL_TEST_TOKEN, tokenAmount, payload),
            abi.encodePacked(r, s, v)
        );

        bytes memory expectedPayload = bytes.concat(
            payload,
            abi.encodePacked(r, s, v)
        );

        deal(address(TOKEN_TO_TEST_WITH), signer, tokenAmount);

        assertEq(
            TOKEN_TO_TEST_WITH.balanceOf(signer),
            tokenAmount,
            "ExecutionTest: ERC20 Deal Did Not Work"
        );

        TOKEN_TO_TEST_WITH.approve(address(diamond), tokenAmount);

        vm.expectEmit(true, true, true, true);
        emit CrosschainBridge(
            SOLANA_CHAIN_ID,
            HXRO_SOLANA_PROGRAM,
            address(TOKEN_TO_TEST_WITH),
            SOL_TEST_TOKEN,
            tokenAmount,
            expectedPayload
        );

        CoreFacet(address(diamond)).executeHxroPayloadWithTokens(
            InboundPayload(SOL_TEST_TOKEN, tokenAmount, payload),
            abi.encodePacked(r, s, v)
        );
    }

    function testNonceManagement(uint256 privKey) external {
        _validateFuzzedKey(privKey);

        address signer = vm.addr(privKey);
        uint256 preNonce = StorageManagerFacet(address(diamond)).getUserNonce(
            address(signer)
        );

        testPlainExecution(privKey);

        assertEq(
            StorageManagerFacet(address(diamond)).getUserNonce(address(signer)),
            preNonce + 1,
            "NonceManagementTest: Nonce Did Not Increase"
        );
    }

    event CrosschainBridge(
        uint256 indexed toChainId,
        bytes32 indexed destAddress,
        address indexed srcToken,
        bytes32 destToken,
        uint256 amtIn,
        bytes payload
    );

    event CrosschainPayloadTransfer(
        uint256 indexed toChainid,
        bytes32 indexed destAddress,
        bytes indexed payload
    );

    function _validateFuzzedKey(uint256 key) internal view {
        vm.assume(key > 10 && key < MAX_PRIV_KEY);
    }
}
