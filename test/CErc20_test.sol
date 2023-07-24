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
        mockERC20 = new MockERC20();
        mockERC20.mint();
        cErc20Delegate = new CErc20Delegate();
        cErc20Delegator =
        new CErc20Delegator(address(mockERC20), comptoller,InterestRateModel(address(jumpRateModel)),initialExchangeRateMantissa_,"test","test",18,payable(address(this)),address(cErc20Delegate),abi.encodePacked(""));
        mockERC20.approve(address(cErc20Delegator), type(uint256).max);
        oracle = new SimplePriceOracle();
        oracle.setUnderlyingPrice(CToken(address(cErc20Delegator)), 1700);
    }

    function test_mint() public {
        comptoller._supportMarket(CToken(address(cErc20Delegator)));
        uint256 mintAmount = 6e18;
        cErc20Delegator.mint(mintAmount);
        uint256 exchangeRate = cErc20Delegator.exchangeRateStored();
        assertEq(cErc20Delegator.balanceOf(address(this)), 6e18 / (exchangeRate / 1e18));
    }

    function test_redeem() public {
        test_mint();
        uint256 result = cErc20Delegator.redeem(cErc20Delegator.balanceOf(address(this)));
        assertEq(result, 0);
    }

    function test_borrow() public {
        test_mint();
        comptoller._setPriceOracle(PriceOracle(address(oracle)));
        comptoller._setCollateralFactor(CToken(address(cErc20Delegator)), 0.9e18);
        uint256 balanceBefore = mockERC20.balanceOf(address(this));
        cErc20Delegator.borrow(5e18);
        uint256 balanceAfter = mockERC20.balanceOf(address(this));
        assertEq(balanceAfter - balanceBefore, 5e18);
    }

    function test_repayBorrow() public {
        test_borrow();
        uint256 balanceBefore = mockERC20.balanceOf(address(this));
        cErc20Delegator.repayBorrow(1e18);
        uint256 balanceAfter = mockERC20.balanceOf(address(this));
        assertEq(balanceBefore - balanceAfter, 1e18);
    }
}
