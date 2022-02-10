//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Flow is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant MaxSupply = 1000;
    uint256 public constant Price = 0.01 ether;
    uint256 public constant MaxPerMint = 5;

    string public baseTokenURI;

    constructor(string memory baseTokenURI) ERC721("NFT Collectible", "FLOW") {
        setBaseURI(baseTokenURI);
    }

    function reserveNFTs() public onlyOwner {
        uint256 totalMinted = _tokenIds.current();
        require(totalMinted.add(10) < MaxSupply, "Not enough NFTs");
        for (uint256 i = 0; i < 10; i++) {
            _mintSingleNFT();
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint256 _mintNumber) public payable {
        uint256 totalMinted = _tokenIds.current();
        require(totalMinted.add(_mintNumber) <= MaxSupply, "Not enough NFTs!");
        require(
            _mintNumber > 0 && _mintNumber <= MaxSupply,
            "Cannot mint the specified number of NFTs."
        );
        require(
            msg.value >= Price.mul(_mintNumber),
            "Not enough ether to make the purchase."
        );
        for (uint256 i = 0; i < _mintNumber; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _holder)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_holder);
        uint256[] memory tokenId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenId[i] = tokenOfOwnerByIndex(_holder, i);
        }
        return tokenId;
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether avaialbe to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer Failed!");
    }
}
