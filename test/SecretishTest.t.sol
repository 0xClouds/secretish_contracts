//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Secretish} from "../src/Secretish.sol";
import {TestERC721} from "../src/TestERC721.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SecretishTest is Test {
    Secretish secretContract;
    TestERC721 nftContract;
    address user1;
    address user2;

    Secretish.TokenType tokenType;
    uint256 tokenId;
    uint256 amount;
    address tokenAddress;

    function setUp() public {
        user1 = makeAddr("santa");
        user2 = makeAddr("elves");
        secretContract = new Secretish(user1);
        nftContract = new TestERC721();
    }

    function test_EtherGifts() public {
        hoax(user1);
        secretContract.giveEther{value: 0.2 ether}();
        (tokenType, tokenId, amount, tokenAddress) = secretContract.getGift(
            user1
        );
        console.log(uint(tokenType), tokenId, amount, tokenAddress);
        assertEq(amount, 0.2 ether);
        assertEq(tokenAddress, address(0));
        assertEq(uint(tokenType), uint(Secretish.TokenType.ETH));
        vm.stopPrank();
    }

    function test_EtherGiftsArray() public {
        hoax(user1);
        secretContract.giveEther{value: 0.2 ether}();
        assertEq(secretContract.givers(0), user1);
    }

    function testFail_EtherGifts(uint96 amountOfEth) public {
        vm.assume(amountOfEth < 0.1 ether);
        hoax(user1);
        secretContract.giveEther{value: amountOfEth}();
    }

    function testFail_giveTwoGifts() public {
        hoax(user1);
        secretContract.giveEther{value: 0.1 ether}();
        vm.expectRevert();
        secretContract.giveEther{value: 0.1 ether}();
    }

    function test_erc721Deposits() public {
        address secretContractAddress = address(secretContract);
        nftContract.mint(user1);
        vm.startPrank(user1);
        /** You actually dont need the approval because its unimportant */
        nftContract.setApprovalForAll(secretContractAddress, true);
        secretContract.giveERC721(address(nftContract), 1);
        (tokenType, tokenId, amount, tokenAddress) = secretContract.getGift(
            user1
        );
        vm.stopPrank();
        assertEq(nftContract.balanceOf(secretContractAddress), 1);
    }
}
