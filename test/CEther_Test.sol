// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Comptroller.sol";
import "../src/CEther.sol";
import {JumpRateModel} from "../src/JumpRateModel.sol";
import {SimplePriceOracle, PriceOracle} from "../src/SimplePriceOracle.sol";

contract CEtherTest is Test {
    Comptroller comptoller;
    JumpRateModel jumpRateModel;
    CEther cether;
    SimplePriceOracle oracle;

    function setUp() public {
        uint256 baseRatePerYear = 20000000000000000;
        uint256 multiplierPerYear = 200000000000000000;
        uint256 jumpMultiplierPerYear = 2000000000000000000;
        uint256 kink_ = 900000000000000000;
        uint256 initialExchangeRateMantissa_ = 200000000000000000000000000;
        uint8 decimals_ = 8;
        comptoller = new Comptroller();
        jumpRateModel = new JumpRateModel(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_);
        cether =
        new CEther(comptoller, InterestRateModel(address(jumpRateModel)), initialExchangeRateMantissa_, "CEther", "cETH", decimals_, payable(address(this)));
        oracle = new SimplePriceOracle();
        oracle.setUnderlyingPrice(CToken(address(cether)), 1700);
    }

    function test_mint() public {
        comptoller._supportMarket(CToken(address(cether)));
        uint256 mintAmount = 6e18;
        cether.mint{value: mintAmount}();
        assertEq(address(cether).balance, 6e18);
    }

    function test_redeem() public {
        test_mint();
        uint256 result = cether.redeem(cether.balanceOf(address(this)));
        assertEq(result, 0);
    }

    function test_borrow() public {
        test_mint();
        comptoller._setPriceOracle(PriceOracle(address(oracle)));
        comptoller._setCollateralFactor(CToken(address(cether)), 0.9e18);
        cether.borrow(5e18);
    }

    function test_repayBorrow() public {
        test_borrow();
        cether.repayBorrow();
    }

    fallback() external payable {}
}
