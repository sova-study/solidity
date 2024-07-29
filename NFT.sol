//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MyNft is ERC721Enumerable, Ownable {

    uint public constant PRICE = 0.005 ether;
    string public baseTokenURI;
    uint[] soldedTokenIds;
    mapping (address => uint[]) nftOwner;
    
    /** 
     * @dev This event is emitted when an NFT is minted.
     * @param senderAddress The address that mints the NFT
     * @param nftToken The ID of the minted NFT
     */
    event MintNft(address senderAddress, uint256 nftToken);

    /**constructor(string memory baseURI, address initialOwner)  ERC721("My nft", "NFT") ERC721Enumerable()  Ownable(initialOwner) {
        setBaseURI(baseURI);  // в таком виде указываем владельца вручную при деплое контракта
    }*/

    // в таком виде владельцем становится тот, кто деплоит контракт
    /**
    * @dev Initializer that can be called by the owner or an authorized address to setup the contract.
    * @param baseURI Base URI of the NFTs.
    */
    constructor(string memory baseURI)  ERC721("My nft", "NFT") ERC721Enumerable()  Ownable(msg.sender) { //The constructor initializes the contract, sets the base URI for token metadata and assigns ownership to the deployer.
        setBaseURI(baseURI);  // в таком виде указываем владельца вручную при деплое контракта
    }
   
   /**
    * @dev Function to return the base URI of the NFTs.
    * @return The base URI.
    */
    function _baseURI() internal view virtual override returns (string memory) { //Returns the base URI for token metadata.
        return baseTokenURI;
    }
    
    /**
     * @dev Function to set the base URI of the NFTs. Can only be called by the owner.
     * @param _baseTokenURI The new base URI
     */
    function setBaseURI(string memory _baseTokenURI) public onlyOwner { //Sets the base URI for token metadata. Can only be called by the owner.
        baseTokenURI = _baseTokenURI;
    }

   /**
    * @dev Modifier to check if an NFT has been reserved or minted. If the token is sold, the transaction will revert.
    * @param _tokenId The ID of the token to check.
    */
   modifier checkTokenStatus(uint _tokenId) { //Modifier that checks if a token is already sold. If it's sold, the transaction will revert.
    bool isTokenSold = false;
    for (uint i = 0; i < soldedTokenIds.length; i++) {
        if (soldedTokenIds[i] == _tokenId) {
            isTokenSold = true;
            break;
        }
    }
    require(!isTokenSold, "Token is sold");
    _;
}

    /**
        * @dev Function to reserve an NFT with a specific tokenId.
        * Can only be called by the contract owner. 
        * If the token is already sold, it will revert.
        * Emits an event MintNft indicating who minted and which token.
        * @param _tokenId The ID of the token to reserve.
        */
   // Reserves an NFT with a specific token ID. Can only be called by the contract owner. If the token is already sold, it will revert. Emits an event indicating who reserved and which token.
    function reserveNFT(uint _tokenId) public onlyOwner checkTokenStatus(_tokenId) {
        _safeMint(msg.sender, _tokenId);
        nftOwner[msg.sender].push(_tokenId);
        soldedTokenIds.push(_tokenId);
        emit MintNft(msg.sender, _tokenId);
    }

    /**
     * @dev Function to mint an NFT with a specific tokenId and price.
     * Requires the caller to send enough ether to purchase the NFTs. 
     * If the token is already sold, it will revert.
     * Emits an event MintNft indicating who minted and which token.
     * @param _tokenId The ID of the token to mint.
     */
    // Mints an NFT with a specific token ID and price. Requires the caller to send enough ether to purchase the NFTs. If the token is already sold, it will revert. Emits an event indicating who minted and which token.
    function mintNFT(uint _tokenId) public payable checkTokenStatus(_tokenId) {
        require(msg.value >= PRICE, "Not enough ether to purchase NFTs.");
        _safeMint(msg.sender, _tokenId);
        soldedTokenIds.push(_tokenId);
        emit MintNft(msg.sender, _tokenId);
    }

    /** @dev Function to return the tokens owned by an owner.
    * @param _owner The address of the owner.
    * @return The list of token IDs owned by the owner.
    */
    function tokensOfOwner(address _owner) external view returns (uint[] memory) { //Returns the token IDs owned by a specific address.
        return nftOwner[_owner];
    }

    /**
    * @dev Function for the owner to withdraw all remaining Ether in the contract. 
    */
    function withdraw() public payable onlyOwner { //Withdraws all ether from the contract to the owner's address. Can only be called by the owner.
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}