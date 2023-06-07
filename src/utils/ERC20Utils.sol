// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/**
 * Utilities for ERC20 internal functions
 */

import {SafeERC20} from "../libraries/SafeERC20.sol";
import {IERC20} from "../interfaces/IERC20.sol";

library ERC20Utils {
    using SafeERC20 for IERC20;

    /**
     * Approve infinite tokens to an address if allowance is insufficient of some amount
     * @param token - The token to potentially approve
     * @param spender - The spender to check the allowance on
     * @param minAllowance - Minimum allowance it must ave
     */
    function _ensureSufficientAllownace(
        IERC20 token,
        address spender,
        uint256 minAllowance
    ) internal {
        if (token.allowance(address(this), spender) < minAllowance)
            token.approve(spender, type(uint256).max);
    }
}
