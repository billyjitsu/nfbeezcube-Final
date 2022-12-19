// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./QRNG.sol";
import "./INFBeez.sol";

/******** TODOs ********

      uncomment out the contract name - line 29
      fix NFT Names - line 310
      UPDDATE to correct price - line 32 - 20 ether
       */

//contract TheCube is ERC1155Supply, ERC2981, Ownable, ReentrancyGuard, QRNG {
contract TestZone is ERC1155Supply, ERC2981, Ownable, ReentrancyGuard, QRNG {
    // Price of one Cube
    uint256 public tokenPrice = 0.0001 ether; //fix price
    uint256 public constant maxTotalSupply = 5000;
    uint256 public maxPurchaseSupply = 2475;
    uint256 public maxClaims = 2525;
    uint256 public maxDAOCube = 225;
    //token ID for how many NFTs
    uint256 public cubesMinted;
    uint256 public DAOCubesMinted;
    // Need to set max for just minted vs claiming
    uint256 public cubesPurchased;
    uint256 public cubesClaimed;

    uint256 private constant Cube = 1;
    uint256 private constant DAOCube = 28; 
    uint256 private seed; 
    uint256 private shifter;

    address public beezSafe;

    bool public paused;

    uint256[] internal tokens = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21 ,22, 23, 24, 25, 26, 27];
    uint256[] internal tokenAmounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    uint256[] internal DAOTokens = [28, 29, 30, 31];
    uint256[] internal DAOTokenAmounts = [1, 1, 1, 1]; 

    string public CubeNFT;
    // NFBeezNFT contract instance
    INFBeez NFBeezNFT;
    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public nfbeezClaimed;
    // Need a mapping for all NFTs minted overall
    mapping(uint256 => uint256) public tokensMinted;

    //events
    event CubeMinted(address minter, uint256 _amount);
    event CubeClaimed(address minter, uint256 _amount);
    event CubeBroken(address minter, uint256 _amount);
    event DaoCubeCreated(address minter, uint256 [] _daoTokens, uint256 [] _amount); 
    event AdminMinted(address [] reciever, uint256 _amount, uint256 _id);

    constructor(
        address _ogNFBeezContract,
        address _airnodeRrp,
        address _royalty,
        string memory _cubeNFT,
        address _beezSafe
    ) ERC1155(_cubeNFT) QRNG(_airnodeRrp) {
        NFBeezNFT = INFBeez(_ogNFBeezContract);

        //set royalty info
        uint96 _royaltyFeesInBips = 500;
        setRoyaltyInfo(_royalty, _royaltyFeesInBips);
        CubeNFT = _cubeNFT;
        beezSafe = _beezSafe;
    }

    function mint(uint256 amount) external payable {
        require(!paused, "Contract Paused");
        require(msg.value >= (tokenPrice * amount), "Ether sent is incorrect"); 
        require(
            (cubesPurchased + amount) <= maxPurchaseSupply,
            "Exceeds the max total supply available PS."
        );
        //Mint tokens to user
        _mint(msg.sender, Cube, amount, "");
        //update amount of cubes minted
        cubesMinted += amount;
        // update amount of just CUBES PURCHASED
        cubesPurchased += amount;
        // Emit the event
        emit CubeMinted(msg.sender, amount);
    }

    /*  
    The nature of the random number request is two transactions to complete
    Pulling a random base number to use and then generate numbers off of the seeded number
    Purely for speed of minting/breaking large amounts
    */

    function breakOpen() external nonReentrant {
        require(!paused, "Contract Paused");
        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");
        _burn(msg.sender, Cube, 1);
        //Recieve random number
        uint256 realRandom = randomize();
        uint256 localRandom = randomNumber();
        uint256 sum = (realRandom + localRandom) % 26;  // 26 nfts
        uint256 randomNFT = sum + 2;

        _mint(msg.sender, randomNFT, 1, "");
        // mapping for token ID for cap checking
        tokensMinted[randomNFT] += 1;
        //request a new base
        makeRequestUint256();
        emit CubeBroken(msg.sender, 1);
    }

    function bulkBreakOpen(uint256 _amount) external nonReentrant {
        require(!paused, "Contract Paused");
        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");
        require(_amount <= cubeSupply, "Requesting more than you have");
        _burn(msg.sender, Cube, _amount);

        for (uint256 i = 0; i < _amount; i++) {
            uint256 localRandom = randomNumber();
            uint256 sum = (seed + localRandom) % 26;  // 26 nfts
            uint256 randomNFT = sum + 2; 

            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1; 
        }

        makeRequestUint256();

        emit CubeBroken(msg.sender, _amount);
    }

    function bulkBreakOpenAll() external nonReentrant {
        require(!paused, "Contract Paused");
        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");
        _burn(msg.sender, Cube, cubeSupply);

        for (uint256 i = 0; i < cubeSupply; i++) {
            uint256 localRandom = randomNumber();
            uint256 sum = (seed + localRandom) % 26;  // adjusting for 26 nfts
            uint256 randomNFT = sum + 2; 

            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1;
        }

        makeRequestUint256();
        emit CubeBroken(msg.sender, cubeSupply);
    }

    function createDAOCube() external nonReentrant {
        require(
            (DAOCubesMinted + 1) <= maxDAOCube,
            "Exceeds the max total supply available"
        );
        require(!paused, "Contract Paused");
        for (uint256 i = 2; i < DAOCube; i++) {
            //go through all the NFTs
            uint256 balance = balanceOf(msg.sender, i);
            require(balance > 0, "Not Complete Set");
        }

        _burnBatch(msg.sender, tokens, tokenAmounts);    
        // create the DAO cube and bonuses
        _mintBatch(msg.sender, DAOTokens, DAOTokenAmounts, "");

        DAOCubesMinted += 1;
        emit DaoCubeCreated(msg.sender, DAOTokens, DAOTokenAmounts);
    }

    //To distribute to participating DAOs 
    // function adminMint(address _reciever,uint256 _amount, uint256 _tokenId) external onlyOwner {
    //     require(!paused, "Contract Paused");
    //     _mint(_reciever, _tokenId, _amount, "");
    //     if(_tokenId == 1){
    //         cubesMinted += _amount;
    //         cubesPurchased += _amount;
    //     }
    //     emit AdminMinted(_reciever, _amount, _tokenId);
    // }

    function adminMint(address[] memory _reciever, uint256 _amount, uint256 _tokenId) external onlyOwner {
        require(
            (cubesPurchased + _amount) <= maxPurchaseSupply,
            "Exceeds the max total supply available PS."
        );
        require(!paused, "Contract Paused");

        for (uint256 i = 0; i < _reciever.length; i++) {
            _mint(_reciever[i], _amount, _tokenId, "");

            if(_tokenId == 1){
            cubesMinted += _amount;
            cubesPurchased += _amount;
        }
        }
        emit AdminMinted(_reciever, _amount, _tokenId);
    }

    function claim() public nonReentrant {
        require(!paused, "Contract Paused");
        address sender = msg.sender;
        // Get the number of NFBeez held by a given sender address
        uint256 balance = NFBeezNFT.balanceOf(sender);
        require(balance > 0, "You dont own any NFBeez NFT's");
        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = NFBeezNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId has not been claimed, increase the amount
            if (!nfbeezClaimed[tokenId]) {
                amount += 1;
                nfbeezClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already claimed all the tokens");
        // Check cap
        require(
            (cubesClaimed + amount) <= maxClaims,
            "Exceeds the max total supply available"
        );
        _mint(msg.sender, Cube, amount, "");

        //update amount of cubes minted
        cubesMinted += amount;
        cubesClaimed += amount;
        emit CubeClaimed(msg.sender, balance);
    }

    function randomize() internal returns (uint256) {
          seed = getRandom();
        return seed;
    }

    function randomNumber () internal returns (uint256) {
        uint256 localRand = (block.difficulty + block.timestamp + shifter) % 7772; 
        shifter = localRand;
        return localRand;
    }

    function name() public pure returns (string memory) {
        return "TEST ZONE";
    }

    function symbol() public pure returns (string memory) {
        return "TEST";
    }

    /*
    function name() public pure returns (string memory) {
        return "The Cube";
    }

    function symbol() public pure returns (string memory) {
        return "CUBE";
    }  
    */

    // URI overide for number schemes
    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(CubeNFT, Strings.toString(_tokenId), ".json")
            );
    }

    //Interface overide for royalties
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981)
        returns (bool)
    {
        return ERC1155.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }

    // Only Owner Functions
    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips)
        public
        onlyOwner
    {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        CubeNFT = _newBaseURI;
    }

    function setNewDAOCubeMax(uint256 _newMax) external onlyOwner {
        maxDAOCube = _newMax;
    }

    //update Beez Safe Wallet
    function updateBeezWallet(address _beezSafe) external onlyOwner {
        beezSafe = _beezSafe;
    }

    //function to pull out token
    function withdrawToken(IERC20 token) external onlyOwner {
        require(
            token.transfer(msg.sender, token.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function withdraw() external onlyOwner {
        uint256 withdrawAmount_25 = ((address(this).balance) * 25) / 100;
        (bool sent, ) = payable(beezSafe).call{value: withdrawAmount_25}("");
        require(sent, "beezsafe not sent");
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Safe not sent");
    }
  
}
