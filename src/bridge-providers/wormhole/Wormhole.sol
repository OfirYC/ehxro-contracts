// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
// import "src/storage/core/bridge-providers/Wormhole.sol";
// import "src/storage/core/Core.sol";
// import {ITokenBridge} from "lib/wormhole/ethereum/contracts/bridge/interfaces/IBridgeProvider.sol";
// import {ERC20Utils} from "src/utils/ERC20Utils.sol";

// /**
//  * Bridge adapter for Wormhole
//  */
// contract WormholeSwapAdapter {
//     // Libs
//     using ERC20Utils for IERC20;

//     // =================
//     //     METHODS
//     // =================
//     /**
//      * Bridge a HXRO payload along with tokens to the Solana program
//      * @param token - The token to bridge
//      * @param amount - The amount to bridge
//      * @param hxroPayload - The HXRO payload to bridge
//      */
//     function wormholeSwapAndBridgePayload(
//         address token,
//         uint256 amount,
//         bytes memory hxroPayload
//     ) external {
//         WormholeAdapterStorage storage wormholeStorage = WormholeStorageLib
//             .retreive();
//         CoreStorage storage coreStorage = WormholeStorageLib.retreive();
//         ITokenBridge tokenBridge = wormholeStorage.tokenBridge;

//         token._ensureSufficientAllownace(address(tokenBridge), amount);

//         tokenBridge.transferTokensWithPayload(
//             token,
//             amount,
//             wormholeStorage.solanaChainId,
//             coreStorage.solanaProgram
//         );
//     }

//     /**
//      * Bridge a HXRO Payload to the Solana program
//      * @param hxroPayload - The hxro payload to bridge
//      */
//     function wormholeBridgePayload(bytes memory hxroPayload) external {
//         uint256 i = 0;
//     }
// }
