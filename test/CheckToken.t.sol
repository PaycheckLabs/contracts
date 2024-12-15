// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "contracts/CheckToken.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract CheckTokenTest is Test, EIP712 {
    CheckToken private token;
    address private owner;
    address private user1;
    address private user2;

    constructor() EIP712("Check Token", "1") {}

    function setUp() public {
        owner = address(this); // Set the deployer as the owner
        user1 = address(0x1234); // Sample user1 address
        user2 = address(0x5678); // Sample user2 address

        token = new CheckToken(); // Deploy the CheckToken contract
    }

    function testInitialSetup() public {
        // Test the name and symbol
        assertEq(token.name(), "Check Token");
        assertEq(token.symbol(), "CHECK");

        // Test the initial supply
        assertEq(token.totalSupply(), token.MAX_SUPPLY());
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY());
    }

    function testTransfer() public {
        uint256 transferAmount = 1e18;

        // Transfer tokens to another user
        token.transfer(user1, transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - transferAmount);
    }

    function testTransferToZeroAddress() public {
        uint256 transferAmount = 1e18;

        // Transfer tokens to the zero address (should fail)
        vm.expectRevert();
        token.transfer(address(0), transferAmount);
    }

    function testFailTransferExceedsBalance() public {
        uint256 transferAmount = token.MAX_SUPPLY() + 1;

        // Attempt to transfer more than the balance (should fail)
        token.transfer(user1, transferAmount);
    }

    function testBurn() public {
        uint256 burnAmount = 1e18;

        // Burn tokens
        token.burn(burnAmount);
        assertEq(token.totalSupply(), token.MAX_SUPPLY() - burnAmount);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - burnAmount);
    }

    function testFailBurnExceedsBalance() public {
        uint256 burnAmount = token.MAX_SUPPLY() + 1;

        // Attempt to burn more than the balance (should fail)
        token.burn(burnAmount);
    }

    function testBurnZeroAmount() public {
        // Burn zero tokens
        uint256 burnAmount = 0;

        token.burn(burnAmount);
        assertEq(token.totalSupply(), token.MAX_SUPPLY());
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY());
    }

    function testApproveAndTransferFrom() public {
        uint256 allowanceAmount = 1e18;
        uint256 transferAmount = 1e18;

        // Approve user1 to spend owner's tokens
        token.approve(user1, allowanceAmount);
        assertEq(token.allowance(owner, user1), allowanceAmount);

        // Simulate user1 transferring from owner to user2
        vm.prank(user1);
        token.transferFrom(owner, user2, transferAmount);

        assertEq(token.balanceOf(user2), transferAmount);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - transferAmount);
        assertEq(token.allowance(owner, user1), allowanceAmount - transferAmount);
    }

    function testFailTransferFromExceedsAllowance() public {
        uint256 allowanceAmount = 1e18;
        uint256 transferAmount = 2e18;

        // Approve user1 to spend owner's tokens
        token.approve(user1, allowanceAmount);

        // Simulate user1 transferring more than allowed (should fail)
        vm.prank(user1);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds allowance"));
        token.transferFrom(owner, user2, transferAmount);
    }

    function testPermit() public {
        (address alice, uint256 key) = makeAddrAndKey("permitUser");
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;
        uint256 value = 1e18;

        bytes32 permitTypeHash =
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
        bytes32 structHash = keccak256(abi.encode(permitTypeHash, alice, user1, value, nonce, deadline));
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Check Token")),
                keccak256(bytes("1")),
                block.chainid,
                address(token)
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);

        // Use the permit
        token.permit(alice, user1, value, deadline, v, r, s);
        assertEq(token.allowance(alice, user1), value);
    }

    function testAllowanceReductionToZero() public {
        uint256 allowanceAmount = 1e18;

        // Approve user1 to spend owner's tokens
        token.approve(user1, allowanceAmount);
        assertEq(token.allowance(owner, user1), allowanceAmount);

        // Reduce allowance to zero
        token.approve(user1, 0);
        assertEq(token.allowance(owner, user1), 0);
    }

    function testTransferAllTokens() public {
        uint256 balance = token.balanceOf(owner);

        // Transfer all tokens to user1
        token.transfer(user1, balance);
        assertEq(token.balanceOf(user1), balance);
        assertEq(token.balanceOf(owner), 0);
    }

    function testBurnFrom() public {
        uint256 burnAmount = 1e18;

        // Approve user1 to burn owner's tokens
        token.approve(user1, burnAmount);

        // Simulate user1 burning owner's tokens
        vm.prank(user1);
        token.burnFrom(owner, burnAmount);

        assertEq(token.totalSupply(), token.MAX_SUPPLY() - burnAmount);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - burnAmount);
    }

    function testFailBurnFromWithoutApproval() public {
        uint256 burnAmount = 1e18;

        // Attempt to burn without approval (should fail)
        vm.prank(user1);
        vm.expectRevert(bytes("ERC20: burn amount exceeds allowance"));
        token.burnFrom(owner, burnAmount);
    }

    function testDecimals() public {
        // Test the decimals function
        assertEq(token.decimals(), 18);
    }

    function testMultipleApprovals() public {
        uint256 firstApproval = 1e18;
        uint256 secondApproval = 2e18;

        // Approve user1 with two different amounts sequentially
        token.approve(user1, firstApproval);
        assertEq(token.allowance(owner, user1), firstApproval);

        token.approve(user1, secondApproval);
        assertEq(token.allowance(owner, user1), secondApproval);
    }

    function testTransferAfterBurn() public {
        uint256 burnAmount = 1e18;
        uint256 transferAmount = 1e18;

        // Burn some tokens first
        token.burn(burnAmount);

        // Transfer tokens after burn
        token.transfer(user1, transferAmount);
        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - burnAmount - transferAmount);
    }

    function testApproveSpenderToZeroThenTransfer() public {
        uint256 initialAllowance = 1e18;
        uint256 transferAmount = 1e18;

        // Approve user1 to spend owner's tokens
        token.approve(user1, initialAllowance);
        assertEq(token.allowance(owner, user1), initialAllowance);

        // Set allowance to zero
        token.approve(user1, 0);
        assertEq(token.allowance(owner, user1), 0);

        // Attempt transferFrom with zero allowance (should fail)
        vm.prank(user1);
        vm.expectRevert();
        token.transferFrom(owner, user2, transferAmount);
    }

    function testBalanceAfterTransferAndBurn() public {
        uint256 transferAmount = 1e18;
        uint256 burnAmount = 1e18;

        // Transfer some tokens to user1
        token.transfer(user1, transferAmount);

        // Burn some tokens from the owner's balance
        token.burn(burnAmount);

        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - transferAmount - burnAmount);
        assertEq(token.balanceOf(user1), transferAmount);
        assertEq(token.totalSupply(), token.MAX_SUPPLY() - burnAmount);
    }

    function testDoubleBurn() public {
        uint256 firstBurn = 1e18;
        uint256 secondBurn = 2e18;

        // Burn tokens twice
        token.burn(firstBurn);
        token.burn(secondBurn);

        assertEq(token.totalSupply(), token.MAX_SUPPLY() - firstBurn - secondBurn);
        assertEq(token.balanceOf(owner), token.MAX_SUPPLY() - firstBurn - secondBurn);
    }
}