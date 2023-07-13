// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Comptroller.sol";
import "../src/CErc20Delegate.sol";
import "./mock/MockERC20.sol";
import "../src/CErc20Delegator.sol";
import {JumpRateModel} from "../src/JumpRateModel.sol";
import {SimplePriceOracle, PriceOracle} from "../src/SimplePriceOracle.sol";

contract CERC20_Test is Test {
    Comptroller comptoller;
    JumpRateModel jumpRateModel;
    CErc20Delegate cErc20Delegate;
    SimplePriceOracle oracle;
    MockERC20 mockERC20;
    CErc20Delegator cErc20Delegator;
    function setUp() public {
        uint256 baseRatePerYear = 20000000000000000;
        uint256 multiplierPerYear = 200000000000000000;
        uint256 jumpMultiplierPerYear = 2000000000000000000;
        uint256 kink_ = 900000000000000000;
        uint256 initialExchangeRateMantissa_ = 200000000000000000000000000;
        comptoller = new Comptroller();
        jumpRateModel = new JumpRateModel(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_);
        MockERC20 mockERC20 = new MockERC20();
        mockERC20.mint();
        cErc20Delegate = new CErc20Delegate();
        cErc20Delegator = new CErc20Delegator(address(mockERC20), comptoller,InterestRateModel(address(jumpRateModel)),initialExchangeRateMantissa_,"test","test",18,payable(address(this)),address(cErc20Delegate),abi.encodePacked(""));
        mockERC20.approve(address(cErc20Delegator),1e19);
        oracle = new SimplePriceOracle();
        oracle.setUnderlyingPrice(CToken(address(cErc20Delegate)), 1700);
    }

    function test_mint() public {
        comptoller._supportMarket(CToken(address(cErc20Delegator)));
        uint256 mintAmount = 1e18;
        cErc20Delegator.mint(mintAmount);
        uint256 exchangeRate = cErc20Delegator.exchangeRateStored();
        assertEq(cErc20Delegator.balanceOf(address(this)), 1e18/(exchangeRate/1e18));
    }
}
