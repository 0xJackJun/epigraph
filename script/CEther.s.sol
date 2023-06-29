// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Comptroller.sol";
import "../src/CEther.sol";
import { JumpRateModel } from "../src/JumpRateModel.sol";
import { SimplePriceOracle, PriceOracle } from "../src/SimplePriceOracle.sol";

contract CEtherScript is Script {
    Comptroller comptoller;
    JumpRateModel jumpRateModel;
    CEther cether;
    SimplePriceOracle oracle;
    function setUp() public {
        uint baseRatePerYear = 20000000000000000;
        uint multiplierPerYear = 200000000000000000;
        uint jumpMultiplierPerYear = 2000000000000000000;
        uint kink_ = 900000000000000000;
        uint initialExchangeRateMantissa_ = 200000000000000000000000000;
        uint8 decimals_ = 8;
        comptoller = new Comptroller();
        jumpRateModel = new JumpRateModel(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_);
        cether = new CEther(comptoller, InterestRateModel(address(jumpRateModel)), initialExchangeRateMantissa_, "CEther", "cETH", decimals_, payable(address(this)));
        oracle = new SimplePriceOracle();
        oracle.setUnderlyingPrice(CToken(address(cether)), 1700);
    }

    function run() public {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);
        setUp();
        vm.stopBroadcast();
    }
}
