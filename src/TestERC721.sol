//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestERC721 is ERC721 {
    uint256 tokenId = 1;

    constructor() ERC721("TestERC", "TEST") {}

    function mint(address to) public {
        _safeMint(to, tokenId);
        tokenId += 1;
    }
}
