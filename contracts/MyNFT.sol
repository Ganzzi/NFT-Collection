// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    struct ListedNFT {
        address seller;
        uint256 price;
        string url;
    }

    mapping(uint256 => ListedNFT) private _activeItem;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") {}

    event NftListingCancelled(uint256 indexed tokenId, address indexed caller);
    event NftListed(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );
    event NftListingUpdated(
        uint256 indexed tokenId,
        address indexed caller,
        uint256 newPrice
    );
    event NftBought(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );

    modifier notListed(uint256 tokenId) {
        ListedNFT memory listing = _activeItem[tokenId];

        if (listing.price > 0) {
            revert("Already listed");
        }
        _;
    }

    modifier isListed(uint256 tokenId) {
        ListedNFT memory listing = _activeItem[tokenId];

        if (listing.price <= 0) {
            revert("Not listed");
        }
        _;
    }

    modifier isOwner(uint256 tokenId, address spender) {
        address owner = ownerOf(tokenId);
        if (spender != owner) {
            revert("You are not the owner");
        }
        _;
    }

    function createNft(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function listNft(
        uint256 tokenId,
        uint256 price
    ) public notListed(tokenId) isOwner(tokenId, msg.sender) {
        require(_exists(tokenId), "Token does not exist");

        string memory _url = tokenURI(tokenId);
        _activeItem[tokenId] = ListedNFT(msg.sender, price, _url);

        emit NftListed(tokenId, msg.sender, price);
    }

    function cancelListing(
        uint256 tokenId
    ) public isListed(tokenId) isOwner(tokenId, msg.sender) {
        delete _activeItem[tokenId];

        emit NftListingCancelled(tokenId, msg.sender);
    }

    function updateListing(
        uint256 tokenId,
        uint256 newPrice
    ) public isListed(tokenId) isOwner(tokenId, msg.sender) {
        _activeItem[tokenId].price = newPrice;

        emit NftListingUpdated(
            _activeItem[tokenId].price,
            msg.sender,
            newPrice
        );
    }

    function buyNft(uint256 tokenId) public payable isListed(tokenId) {
        require(_activeItem[tokenId].seller != address(0), "Token not listed");
        require(
            msg.sender != _activeItem[tokenId].seller,
            "Can Not buy your own NFT"
        );

        require(msg.value >= _activeItem[tokenId].price, "Not enough money!");

        ListedNFT memory listedItem = _activeItem[tokenId];

        delete _activeItem[tokenId];
        _transfer(listedItem.seller, msg.sender, tokenId);

        // Send the correct amount of wei to the seller
        (bool success, ) = payable(listedItem.seller).call{value: msg.value}(
            ""
        );
        require(success, "Payment failed");

        emit NftBought(tokenId, listedItem.seller, msg.sender, msg.value);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getActiveItem(
        uint256 tokenId
    ) public view returns (ListedNFT memory) {
        return _activeItem[tokenId];
    }
}
