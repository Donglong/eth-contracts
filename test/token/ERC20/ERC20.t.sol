// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import {ERC20} from "../../../src/token/ERC20/ERC20.sol";

contract ERC20Test is Test {
    string constant TOKEN_NAME = "My Token";
    string constant TOKEN_SYMBOL = "STKN";
    uint8 constant TOKEN_DECIMALS = 18;

    ERC20 internal token;

    address internal deployer;
    address internal recipient;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed to, uint256 value);

    function setUp() external {
        deployer = address(this);
        recipient = msg.sender;

        token = new ERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, 10000);
    }

    function test_Name() external {
        assertEq(TOKEN_NAME, token.name());
    }

    function test_Symbol() external {
        assertEq(TOKEN_SYMBOL, token.symbol());
    }

    function test_Decimals() external {
        assertEq(TOKEN_DECIMALS, token.decimals());
    }

    function test_TotalSupply() external {
        assertEq(10000, token.totalSupply());
    }

    function test_BalanceOf() external {
        assertEq(10000, token.balanceOf(deployer));
    }

    function test_Transfer() external {
        vm.expectEmit(true, true, false, true);

        emit Transfer(deployer, recipient, 100);

        token.transfer(recipient, 100);

        assertEq(100, token.balanceOf(recipient));
        assertEq(10000 - 100, token.balanceOf(deployer));
    }

    function test_Transfer_CanTransferZeroValue() external {
        vm.expectEmit(true, true, false, true);

        emit Transfer(deployer, recipient, 0);

        token.transfer(recipient, 0);

        assertEq(0, token.balanceOf(recipient));
        assertEq(10000 - 0, token.balanceOf(deployer));
    }

    function test_Transfer_RevertIf_NotEnoughBalance() external {
        vm.expectRevert(bytes("Not Enough Balance."));
        token.transfer(recipient, 10000 + 10);
    }

    function test_TransferFrom() external {
        address spender = address(1);
        token.approve(spender, 5000);

        vm.expectEmit(true, true, false, true);
        emit Transfer(deployer, recipient, 1000);

        vm.startPrank(spender);
        token.transferFrom(deployer, recipient, 1000);

        assertEq(9000, token.balanceOf(deployer));
        assertEq(1000, token.balanceOf(recipient));
        assertEq(4000, token.allowance(deployer, spender));
    }

    function test_TransferFrom_CanTransferZeroValue() external {
        address spender = address(1);
        vm.expectEmit(true, true, false, true);

        emit Transfer(deployer, recipient, 0);

        vm.startPrank(spender);
        token.transferFrom(deployer, recipient, 0);

        assertEq(10000, token.balanceOf(deployer));
        assertEq(0, token.balanceOf(recipient));
    }

    function test_TransferFrom_RevertIf_NotEnoughAllowance() external {
        address spender = address(1);
        vm.expectRevert(bytes("Not Enough Allowance."));

        vm.startPrank(spender);
        token.transferFrom(deployer, recipient, 10);
    }

    function test_TransferFrom_RevertIf_NotEnoughBalance() external {
        address spender = address(1);

        token.approve(spender, 5000);
        token.transfer(recipient, 5100);

        vm.expectRevert(bytes("Not Enough Balance."));
        vm.startPrank(spender);
        token.transferFrom(deployer, recipient, 5000);
    }

    function test_Approve() external {
        address spender = address(1);
        vm.expectEmit(true, true, false, true);

        emit Approval(deployer, spender, 5000);

        token.approve(spender, 5000);

        assertEq(5000, token.allowance(deployer, spender));
    }

    function test_Approve_RevertIf_NotEnoughBalance() external {
        address spender = address(1);
        vm.expectRevert(bytes("Not Enough Balance."));
        token.approve(spender, 10001);
    }

    function test_Allowance() external {
        address spender = address(1);
        token.approve(spender, 5000);
        assertEq(5000, token.allowance(deployer, spender));
    }
}
