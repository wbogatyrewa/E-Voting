// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "./ERC20Standard.sol";

contract Token is ERC20Standard {
	
    constructor() {
      name = "E-Voting coin";
      decimals = 0;
      symbol = "EVC";
    }
}