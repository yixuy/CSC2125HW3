// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

contract SampleCoin is ERC20 {
    // your code goes here (you can do it!)
    // TOKEN CONTRACT (WITH 18 DECIMALS)
    constructor() ERC20("SampleCoin", "SAM") {
        // ("100", 18)
        _mint(msg.sender, 100 * 1e18);
    }
}