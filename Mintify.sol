// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMinter is ERC721URIStorage, Ownable {
    uint256 public nextTokenId = 0; // Initialize nextTokenId
    uint256 public maxSupply;
    uint256 public mintPrice;
    bool public saleActive;

    mapping(address => bool) public hasMinted;

    event NFTMinted(address indexed minter, uint256 tokenId, string tokenURI);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _mintPrice
    ) ERC721(_name, _symbol) Ownable(msg.sender) { // Explicitly initialize Ownable
        maxSupply = _maxSupply;
        mintPrice = _mintPrice;
        saleActive = false; // Start with sale inactive
    }

    function toggleSale() external onlyOwner {
        saleActive = !saleActive;
    }

    function mintNFT(string memory _tokenURI) external payable {
        require(saleActive, "Minting is not active");
        require(nextTokenId < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient ETH sent");
        require(!hasMinted[msg.sender], "You have already minted an NFT");

        uint256 tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        hasMinted[msg.sender] = true;
        nextTokenId++;

        emit NFTMinted(msg.sender, tokenId, _tokenURI);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function totalMinted() external view returns (uint256) {
        return nextTokenId;
    }
}
