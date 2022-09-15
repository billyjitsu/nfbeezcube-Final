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
      uncomment out Mint payment req Line 62
      ultimately remove NFT.sol (add in beez contract)
      uncomment out the contract name - line 20
      fix NFT Names - line 221
      UPDDATE to correct price
      Possible Mint bonus for DAO Cube
      create events - cubes created.. etc

      check each bulk burn for 27 max

      on QRNG.sol
      linet 15 make private
      change line 66 mod 25 (change to new number)
       */

//contract BeezCube is ERC1155Supply, ERC2981, Ownable, ReentrancyGuard, QRNG {
contract TestZone is ERC1155Supply, ERC2981, Ownable, ReentrancyGuard, QRNG {
    // Price of one Cube
    uint256 public tokenPrice = 0.0001 ether; //fix price
    uint256 public constant maxTotalSupply = 5000;
    uint256 public maxPurchaseSupply = 2475; //5,000 - claimable (2525)
    uint256 public maxClaims = 2525;
    uint256 public maxDAOCube = 200;
    //token ID for how many NFTs
    uint256 public cubesMinted;
    uint256 public DAOCubesMinted;
    // Need to set max for just minted vs claiming
    uint256 public cubesPurchased;
    uint256 public cubesClaimed;

    uint256 private constant Cube = 1;
    uint256 private constant DAOCube = 27; //change to new numbers
    uint256 private seed;
    uint256 private shifter;
    uint256 private previousRandom;
    //Payout addresses
    address public artist;
    address public beezSafe;
    address public donation;
    // Pause all mint and claim activity
    bool public paused;

    string public CubeNFT;
    // NFBeezNFT contract instance
    INFBeez NFBeezNFT;
    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public nfbeezClaimed;
    // Need a mapping for all NFTs minted overall
    mapping(uint256 => uint256) public tokensMinted;

    //events
    event CubeMinted(address minter, uint256 _amount);

    event DaoCubeCreated(address minter); //token ID

    constructor(
        address _ogNFBeezContract,
        address _airnodeRrp,
        address _royalty,
        string memory _cubeNFT,
        address _artist,
        address _beezSafe,
        address _donation
    ) ERC1155(_cubeNFT) QRNG(_airnodeRrp) {
        NFBeezNFT = INFBeez(_ogNFBeezContract);

        //set royalty info
        uint96 _royaltyFeesInBips = 500;
        setRoyaltyInfo(_royalty, _royaltyFeesInBips);
        CubeNFT = _cubeNFT;
        artist = _artist;
        beezSafe = _beezSafe;
        donation = _donation;
    }

    function mint(uint256 amount) external payable {
        //uncomment out the fee for mint

        //require not paused
        require(!paused, "Contract Paused");
        // the value of ether that should be equal or greater than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        require(
            (cubesMinted + amount) <= maxTotalSupply,
            "Exceeds the max total supply available TS."
        );
        require(
            (cubesMinted + amount) <= maxPurchaseSupply,
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

    function breakOpen() external nonReentrant {
        // add nonrentrant
        //require not paused
        require(!paused, "Contract Paused");
        //Check the balance of Cubes
        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");
        _burn(msg.sender, Cube, 1);
        //Recieve random number
        uint256 realRandom = randomize();

        uint256 localRandom = randomNumber();

        uint256 sum = (realRandom + localRandom) % 25;  // adjusting for 25 nfts
        uint256 randomNFT = sum + 2; //offset 0 and 1

        // check to see if it is the same number that was previously minted
        //if (randomNFT == previousRandom) {
        //    randomNFT = randomize(); // change the number
        //}

        _mint(msg.sender, randomNFT, 1, "");
        // mapping for token ID for cap checking
        tokensMinted[randomNFT] += 1;
        //Set a variable to check against on next run
        //previousRandom = randomNFT;
    }

    function bulkBreakOpen(uint256 _amount) external nonReentrant {
        //require not paused
        require(!paused, "Contract Paused");

        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");

        require(_amount <= cubeSupply, "Requesting more than you have");
        _burn(msg.sender, Cube, _amount);


        //Pull a true random first
        //Recieve random number
        uint256 realRandom = randomize();


        //loop through but create a random number for each one
        for (uint256 i = 0; i < _amount; i++) {
            //randomize
            uint256 localRandom = randomNumber();
            uint256 sum = (realRandom + localRandom) % 25;  // adjusting for 25 nfts
            uint256 randomNFT = sum + 2; //offset 0 and 1

            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1; // mapping for token ID
        }
        /*
        //loop through but create a random number for each one
        for (uint256 i = 0; i < _amount; i++) {
            uint256 randomNFT = randomize();
            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1; // mapping for token ID
        }
        */
    }

    function bulkBreakOpenAll() external nonReentrant {
        // add nonrentrant
        //require not paused
        require(!paused, "Contract Paused");

        uint256 cubeSupply = balanceOf(msg.sender, Cube);
        require(cubeSupply > 0, "Need a cube");
        _burn(msg.sender, Cube, cubeSupply);

        //Pull a true random first
        //Recieve random number
        uint256 realRandom = randomize();

        //loop through but create a random number for each one
        for (uint256 i = 0; i < cubeSupply; i++) {
            //randomize
            uint256 localRandom = randomNumber();
            uint256 sum = (realRandom + localRandom) % 25;  // adjusting for 25 nfts
            uint256 randomNFT = sum + 2; //offset 0 and 1

            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1; // mapping for token ID
        }


        /*
        //loop through but create a random number for each one
        for (uint256 i = 0; i < cubeSupply; i++) {
            uint256 randomNFT = randomize();
            _mint(msg.sender, randomNFT, 1, "");
            tokensMinted[randomNFT] += 1; // mapping for token ID
        }
        */
    }

    function createDAOCube() external nonReentrant {  // add virtual upgrade option
        // add nonrentrant
        //Create a cap for DAO cubes
        require(
            (DAOCubesMinted + 1) <= maxDAOCube,
            "Exceeds the max total supply available"
        );
        //require not paused
        require(!paused, "Contract Paused");
        for (uint256 i = 2; i < 27; i++) {
            //go through all the NFTs
            uint256 balance = balanceOf(msg.sender, i);
            require(balance > 0, "Not Complete Set");
        }

        for (uint256 i = 2; i < 27; i++) { //Check this burn number 
            _burn(msg.sender, i, 1);
        }

        // create the DAO cube
        _mint(msg.sender, DAOCube, 1, "");

        DAOCubesMinted += 1;

        // Emit the event
        emit DaoCubeCreated(msg.sender);
    }

    //To distribute to participating DAOs - Will include in total Mints
    function adminMint(uint256 _amount, uint256 _tokenId) external onlyOwner {
        //require not paused
        require(!paused, "Contract Paused");
        require(
            (cubesMinted + _amount) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        require(
            (cubesMinted + _amount) <= maxPurchaseSupply,
            "Exceeds the max total supply available."
        );
        _mint(msg.sender, _tokenId, _amount, "");
        //update _amount of cubes minted
        cubesMinted += _amount;
        // update _amount of just CUBES PURCHASED
        cubesPurchased += _amount;
    }

    function claim() public nonReentrant {
        //require not paused
        require(!paused, "Contract Paused");
        address sender = msg.sender;
        // Get the number of NFBeez held by a given sender address
        uint256 balance = NFBeezNFT.balanceOf(sender);
        // If the balance is zero, revert the transaction
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
    }

    function randomize() internal returns (uint256) {
        // Make request to QRNG
        makeRequestUint256();
        // Add an additional seed
     //   uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 25;
        //Get return form QRNG
     //   uint256 rng = getRandom();
        //add the sum
     //   uint256 sum = (randomNumber + rng) % 25;
     //   seed = sum + 2; //offset 0 and 1
          seed = getRandom();
        return seed;
    }

    function randomNumber () internal view returns (uint256) {
        // Add an additional seed
        uint256 localRand = (block.difficulty + block.timestamp + shifter) % 25;
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
        return "NFBeez Cube";
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
        return super.supportsInterface(interfaceId);
    }

    // Only Owner Functions
    //Change Royalty info
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
        maxDAOCube = _newMax; //Incase Tokens go offbalance
    }

    //update artist wallet
    function updateArtistWallet(address _artist) external onlyOwner {
        artist = _artist;
    }

    //update Beez Safe Wallet
    function updateBeezWallet(address _beezSafe) external onlyOwner {
        beezSafe = _beezSafe;
    }

    // update Donations Wallet
    function updateDonationWallet(address _donation) external onlyOwner {
        donation = _donation;
    }

    //function to pull out token
    function withdrawToken(IERC20 token) external onlyOwner {
        require(
            token.transfer(msg.sender, token.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    // Pull Payments
    function withdraw() external onlyOwner {
        //5%  calculation
        uint256 withdrawAmount_5 = ((address(this).balance) * 5) / 100;
        //20%
        uint256 withdrawAmount_20 = ((address(this).balance) * 20) / 100;

        (bool success, ) = payable(artist).call{value: withdrawAmount_20}("");
        require(success, "artist not sent");
        (bool sent, ) = payable(beezSafe).call{value: withdrawAmount_20}("");
        require(sent, "beezsafe not sent");
        (bool don, ) = payable(msg.sender).call{value: withdrawAmount_5}("");
        require(don, "donation not sent");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
