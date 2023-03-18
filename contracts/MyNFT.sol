// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title An NFT collection for users
/// @author your name goes here
contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage {
    // contract inherits from ERC721, ERC721Enumerable, ERC721URIStorage and Ownable contracts
    using Counters for Counters.Counter;

    // struct to store NFT details for sale
    struct ListedNFT {
        address seller; // seller address
        uint256 price; // sale price
        string url; // NFT URI
    }

    mapping(uint256 => ListedNFT) private activeItem; // map NFT tokenId to ListedNFT struct, activeItem store array of item listed into marketplace

    Counters.Counter private _tokenIdCounter; // counter to generate unique token ids

    constructor() ERC721("MyNFT", "MNFT") {} // constructor to initialize the contract with name "MyNFT" and symbol "MNFT"

    event NftListingCancelled(uint256 indexed tokenId, address indexed caller); // event emitted when an NFT listing is cancelled
    event NftListed(uint256 indexed tokenId, address indexed buyer, uint256 price); // event emitted when an NFT is listed for sale
    event NftListingUpdated(
        uint256 indexed tokenId,
        address indexed caller,
        uint256 newPrice
    ); // event emitted when an NFT listing is updated
    event NftBought(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    ); // event emitted when an NFT is bought


    // modifier to check if an NFT is listed for sale
    modifier isListed(uint256 tokenId) {
        require(activeItem[tokenId].price > 0, "Not listed");
        _;
    }

    // modifier to check if the caller is the owner of the NFT
    modifier isOwner(uint256 tokenId) {
        require(msg.sender == ownerOf(tokenId), "You are not the owner");
        _;
    }

    /// @notice mints an nft
    /// @param to The address to which the Nft will be minted
    /// @param uri The Nft uri that holds the Nft meta data
    function mintNft(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId); // mint a new NFT and assign it to the given address
        _setTokenURI(tokenId, uri); // set the URI of the NFT
    }

    /// @notice lists a minted Nft making it available in the marketplace
    /// @param tokenId The tokenId of the Nft to be listed
    /// @param price The price of the Nft to be listed
    function listNft(
        uint256 tokenId,
        uint256 price
    ) public isListed(tokenId) isOwner(tokenId) {
        string memory _url = tokenURI(tokenId);

        activeItem[tokenId] = ListedNFT(msg.sender, price, _url); // push item into the array that store listedItem
        emit NftListed(tokenId, msg.sender, price);
    }

    /// @notice deletes an item in the activeItem mapping
    /// @dev uses the modifiers isListed to check is item is listed and isOwner to give access to only the listedItem owner
    /// @param tokenId The tokenid of the listedItem to be deleted
    function cancelListing(uint256 tokenId) public isListed(tokenId) isOwner(tokenId) {
        delete activeItem[tokenId];
        emit NftListingCancelled(tokenId, msg.sender);
    }
    
    /// @notice updates the price of the listed Nft
    /// @dev uses the modifiers isListed to check is item is listed and isOwner to give access to only the listedItem owner
    /// @param tokenId The tokenid of the listedItem to be deleted
    /// @param newPrice The new price of the Nft
    function updateListing(uint256 tokenId, uint256 newPrice) public isListed(tokenId) isOwner(tokenId) {
        activeItem[tokenId].price = newPrice;

        emit NftListingUpdated(
            activeItem[tokenId].price,
            msg.sender,
            newPrice
        );
    }

    /// @notice buys a listed Nft and transfer ownership from the seller to the buyer of the Nft
    /// @dev uses the modifiers isListed to check is item is listed
    /// @param tokenId The tokenid of the listedItem to be deleted
    function buyNft(uint256 tokenId) public payable isListed(tokenId) {
        require(msg.sender != activeItem[tokenId].seller, "Can Not buy your own NFT");
        require(msg.value >= activeItem[tokenId].price, "Not enough money!");

        address seller = activeItem[tokenId].seller;
        if(seller != address(0)) {
            ListedNFT memory listedItem = activeItem[tokenId];
            _transfer(listedItem.seller, msg.sender, tokenId);

            // Send the correct amount of wei to the seller
            (bool success, ) = payable(listedItem.seller).call{value: msg.value}("");
            require(success, "Payment failed");

            delete activeItem[tokenId]; // when buy successfully, the new owner need to list again that it could be in the marketplace
            emit NftBought(tokenId, listedItem.seller, msg.sender, msg.value);
        }
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
        // function go get URI of created NFT
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
        // function to get the array that store item that listed
        return activeItem[tokenId];
    }
}
