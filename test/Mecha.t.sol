// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Mecha.sol";

contract MechaTest is Test {
    Mecha public mecha;
    address public user1 = address(0x1);
    
    function setUp() public {
        mecha = new Mecha();
        vm.deal(user1, 10 ether);  // Dá ETH para user1
    }
    
    function testMint() public {
        vm.prank(user1);  // Próxima chamada será de user1
        uint256 tokenId = mecha.mint{value: 0.001 ether}();
        
        assertEq(mecha.ownerOf(tokenId), user1);
        assertEq(mecha.balanceOf(user1), 1);
    }
    
    function testMintWithWrongPrice() public {
        vm.prank(user1);
        vm.expectRevert("Invalid amount of ether");
        mecha.mint{value: 0.002 ether}();
    }
}