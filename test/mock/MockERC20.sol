// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20("Test", "Test") {
    function mint() public {
        _mint(msg.sender, 1e19);
    }
}