// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./MechaTest.t.sol";

contract MechaTransferTest is MechaTest {
    
    uint256 amount;

    function setUp() public override {
        super.setUp();
        amount = mecha.MINT_PRICE();
    }
    
    function testTransferByOwner() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.transferFrom(user1, user2, tokenId);
        
        assertEq(mecha.ownerOf(tokenId), user2);
        
        assertEq(mecha.balanceOf(user1), 0);
        assertEq(mecha.balanceOf(user2), 1);
    }
    
    function testTransferEmitsEvent() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.expectEmit(true, true, true, false);
        emit Transfer(user1, user2, tokenId);
        
        vm.prank(user1);
        mecha.transferFrom(user1, user2, tokenId);
    }
    
    function testTransferResetsApproval() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.approve(user3, tokenId);
        
        assertEq(mecha.getApproved(tokenId), user3);
        
        vm.prank(user1);
        mecha.transferFrom(user1, user2, tokenId);
        
        assertEq(mecha.getApproved(tokenId), address(0));
    }
    
    function testTransferMultipleTokens() public {
        vm.startPrank(user1);
        uint256 token1 = _mint(amount);
        uint256 token2 = _mint(amount);
        uint256 token3 = _mint(amount);
        
        mecha.transferFrom(user1, user2, token1);
        mecha.transferFrom(user1, user2, token2);
        mecha.transferFrom(user1, user3, token3);
        vm.stopPrank();
        
        assertEq(mecha.balanceOf(user1), 0);
        assertEq(mecha.balanceOf(user2), 2);
        assertEq(mecha.balanceOf(user3), 1);
        
        assertEq(mecha.ownerOf(token1), user2);
        assertEq(mecha.ownerOf(token2), user2);
        assertEq(mecha.ownerOf(token3), user3);
    }
    
    function testSelfTransfer() public {
        vm.startPrank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.expectRevert();
        mecha.transferFrom(user1, user1, tokenId);
        
        assertEq(mecha.ownerOf(tokenId), user1);
        assertEq(mecha.balanceOf(user1), 1);
    }
    
    function testTransferByApprovedAddress() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.approve(user2, tokenId);
        
        vm.prank(user2);
        mecha.transferFrom(user1, user3, tokenId);
        
        assertEq(mecha.ownerOf(tokenId), user3);
    }
    
    function testTransferByOperator() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.setApprovalForAll(user2, true);
        
        vm.prank(user2);
        mecha.transferFrom(user1, user3, tokenId);
        
        assertEq(mecha.ownerOf(tokenId), user3);
    }
    
    function testTransferDoesNotAffectOperatorApproval() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.setApprovalForAll(user2, true);
        
        vm.prank(user1);
        mecha.transferFrom(user1, user3, tokenId);
        
        assertTrue(mecha.isApprovedForAll(user1, user2));
    }
    
    function testTransferWithoutPermission() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user2);
        vm.expectRevert();
        mecha.transferFrom(user1, user2, tokenId);
    }
    
    function testTransferToZeroAddress() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        vm.expectRevert();
        mecha.transferFrom(user1, address(0), tokenId);
    }
    
    function testTransferNonExistentToken() public {
        vm.prank(user1);
        vm.expectRevert();
        mecha.transferFrom(user1, user2, 999);
    }
    
    function testTransferFromWrongOwner() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        vm.expectRevert();
        mecha.transferFrom(user2, user1, tokenId);
    }
    
    function testTransferAfterApprovalRevoked() public {
        vm.prank(user1);
        uint256 tokenId = _mint(amount);
        
        vm.prank(user1);
        mecha.approve(user2, tokenId);
        
        vm.prank(user1);
        mecha.approve(address(0), tokenId);
        
        vm.prank(user2);
        vm.expectRevert();
        mecha.transferFrom(user1, user3, tokenId);
    }
}