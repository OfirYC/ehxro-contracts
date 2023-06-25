// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "src/diamond/storage/core/bridge-providers/MayanSwap.sol";
import "src/diamond/AccessControl.sol";

contract MayanStorageManager is AccessControlled {
    // ==============
    //    SETTERS
    // ==============
    function setMayanBridgeContract(
        address newBridgeContract
    ) external onlyOwner {}

    function setMayanAuctionProgram(
        bytes32 newAuctionProgram
    ) external onlyOwner {}

    function setSolSwapFee(uint256 newConstantSolFee) external onlyOwner {}

    function setSolanaChainId(uint16 newChainId) external onlyOwner {}

    function setATA(bytes32 solToken, bytes32 ata) external onlyOwner {}

    // ==============
    //    GETTERS
    // ==============
    function mayanswap() public view returns (address mayanswapBridge) {
        mayanswapBridge = MayanSwapStorageLib.mayanswap();
    }

    function mayanAuctionProgram()
        internal
        view
        returns (bytes32 mayanSolAuctionProgram)
    {
        mayanSolAuctionProgram = MayanSwapStorageLib.mayanAuctionProgram();
    }

    function solSwapFee() internal view returns (uint256 solConstantFee) {
        solConstantFee = MayanSwapStorageLib.solSwapFee();
    }

    function localRefundFee() internal view returns (uint256 refundFee) {
        refundFee = MayanSwapStorageLib.localRefundGas() * tx.gasprice;
    }

    function solanaChainId() internal view returns (uint16 solChainId) {
        solChainId = MayanSwapStorageLib.solanaChainId();
    }

    function getMayanAssociatedTokenAccount(
        bytes32 solToken
    ) internal view returns (bytes32 ata) {
        ata = MayanSwapStorageLib.getMayanAssociatedTokenAccount(solToken);
    }
}
