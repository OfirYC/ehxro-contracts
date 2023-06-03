// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/**
 * Utilities for ERC20 internal functions
 */

import {SafeERC20} from "../libraries/SafeERC20.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract ERC20Utils {
    using SafeERC20 for IERC20;
}
