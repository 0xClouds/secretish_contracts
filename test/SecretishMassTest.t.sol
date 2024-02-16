//SPDX-License-Identifer:MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Secretish} from "../src/Secretish.sol";
import {TestERC721} from "../src/TestERC721.sol";

contract SecretishMassTest is Test {
    address owner = makeAddr("owner");
    Secretish secretContract;
    TestERC721 nftContract;
    address[20] users;

    Secretish.TokenType tokenType;
    uint256 tokenId;
    uint256 value;
    address tokenAddress;

    function setUp() public {
        for (uint i = 0; i < 20; i++) {
            address temp = vm.addr(i + 1);
            vm.deal(temp, 10 ether);
            users[i] = temp;
        }

        secretContract = new Secretish(owner);
        nftContract = new TestERC721();
    }

    function test_MultiEntryWithEther() public {
        for (uint i = 0; i < 10; i++) {
            vm.prank(users[i]);
            secretContract.giveEther{value: 1 ether}();
            (tokenType, tokenId, value, tokenAddress) = secretContract.getGift(
                users[i]
            );
            assertEq(uint(tokenType), uint(Secretish.TokenType.ETH));
            assertEq(tokenId, 0);
            assertEq(value, 1 ether);
            assertEq(tokenAddress, address(0));
        }
    }

    function test_MultiEntryWithERC721() public {
        address secretContractAddress = address(secretContract);
        for (uint i = 0; i < 10; i++) {
            vm.startPrank(users[i]);
            nftContract.mint(users[i]);
            nftContract.setApprovalForAll(secretContractAddress, true);
            secretContract.giveERC721(address(nftContract), i + 1);
            (tokenType, tokenId, value, tokenAddress) = secretContract.getGift(
                users[i]
            );
            assertEq(uint(tokenType), uint(Secretish.TokenType.ERC721));
            assertEq(tokenId, i + 1);
            assertEq(value, 1);
            assertEq(tokenAddress, address(nftContract));
            vm.stopPrank();
        }
    }
}
