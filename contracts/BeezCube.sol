  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

  import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "@openzeppelin/contracts/utils/Strings.sol";
  import "./INFBeez.sol";

  import "hardhat/console.sol";

  contract BeezCube is ERC1155, Ownable {
      // Price of one Cube 
      uint256 public tokenPrice = 0.001 ether;
      uint256 public constant maxTotalSupply = 5000;
      uint256 public maxPurchaseSupply = 2475; //5,000 - claimable (2525)

      uint256 public constant Cube = 1;
      uint256 private constant NFT2 = 2;
      uint256 private constant NFT3 = 3;
      //
      uint256 public constant DAOCube = 27;
      //token ID for how many NFTs
      uint256 public cubesMinted;
      uint256 private seed;
      // Need to set max for just minted vs claiming
      uint256 public cubesPurchased;
      uint256 public cubesClaimed;
      uint256 public maxAmounts = 200; //max amounts for each NFT token (for 25) << from ERC1155 video web3club
      uint256 [] public NFTSMinted = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; //<<< 25 row array
      

      string public CubeNFT =  'ipfs://Qmf5DJLJCgZFaPa1U9qUKTYEnqCFoBk8xH7mnrMtfGga8D/';  
      // NFBeezNFT contract instance
      INFBeez NFBeezNFT;
      // Mapping to keep track of which tokenIds have been claimed
      mapping(uint256 => bool) public tokenIdsClaimed;
      //supply balance of msg.sender
      mapping(address => mapping (uint256 => uint256))  public supplyBalance;

      constructor(address _ogNFBeezContract) ERC1155(CubeNFT) {
          NFBeezNFT = INFBeez(_ogNFBeezContract);
      }

     
      function mint(uint256 amount) external payable { //uncomment out the fee for mint
          // the value of ether that should be equal or greater than tokenPrice * amount;
          uint256 _requiredAmount = tokenPrice * amount;
        //    require(msg.value >= _requiredAmount, "Ether sent is incorrect"); <<< The fee
          require(
              (cubesMinted + amount) <= maxTotalSupply,
              "Exceeds the max total supply available."
          );
          require(
              (cubesMinted + amount) <= maxPurchaseSupply,
              "Exceeds the max total supply available."
          );
          
          _mint(msg.sender, Cube, amount, "");
          //update msg.sender balance
          supplyBalance[msg.sender][Cube] += amount;
          //update amount of cubes minted
          cubesMinted += amount;
          // update amount of just CUBES PURCHASED
          cubesPurchased += amount;
      }

      function breakOpen() external { // add nonrentrant
            //add a requirement of checking the mapping to make sure they own it
           // uint256 cubeSupply = supplyBalance[msg.sender][Cube];
           uint256 previousRandom; // <<< set a previous random checker
            uint256 cubeSupply = balanceOf(msg.sender, Cube);
            require(cubeSupply > 0, 'Need a cube');
            _burn(msg.sender, Cube, 1);
            supplyBalance[msg.sender][Cube] -= 1;
            //start random number
            uint256 randomNFT = randomize();
            // check to see if it is the same number that was previously minted
            if(randomNFT == previousRandom) { 
                randomNFT = randomize(); // change the number
            }
            //require that not to many of the same tokens are minted by chance. if it is .. run again.
            _mint(msg.sender, randomNFT, 1, ""); //randomize this
            previousRandom =  randomNFT;
      }

      function bulkBreakOpen() external { // add nonrentrant
            uint256 cubeSupply = balanceOf(msg.sender, Cube);
            require(cubeSupply > 0, 'Need a cube');
            _burn(msg.sender, Cube, cubeSupply);
            supplyBalance[msg.sender][Cube] -= cubeSupply;

            //loop through but create a random number for each one
            for (uint256 i = 0; i < cubeSupply; i++) {
                //start random number
                uint256 randomNFT = randomize();
                //require that not to many of the same tokens are minted by chance. if it is .. run again.
                _mint(msg.sender, randomNFT, 1, ""); //randomize this
            }
      }

      function createDAOCube() external { // add nonrentrant
            //add a requirement of checking if they have all NFTs
            //  check this function balanceOfBatch(address[] memory accounts, uint256[] memory ids) // kinda does the same thing
            for (uint256 i = 2; i < 27; i++) { //go through all the NFTs
            uint256 balance = balanceOf(msg.sender, i );  //function balanceOf(address account, uint256 id) 
            require(balance > 0, 'Not Complete Set');
            }

          // uint256 cardSupply = supplyBalance[msg.sender][Cube]; // Need to check to make sure each token is in possession
          //  require(cubeSupply > 0, 'Need a cube');
          // batch burn   _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts)
            _burn(msg.sender, Cube, 1); // fix this
            supplyBalance[msg.sender][Cube] -= 1;  // fix this
            //start random number
            uint256 randomNFT = randomize();
            _mint(msg.sender, DAOCube, 1, ""); // create the DAO cube Token 27
      }

      function adminMint(uint256 _amount, uint256 _tokenId) external onlyOwner {
         require((cubesMinted + amount) <= maxTotalSupply, "Exceeds the max total supply available.");
         require((cubesMinted + amount) <= maxPurchaseSupply, "Exceeds the max total supply available.");
         _mint(msg.sender, _tokenId, _amount, "");
         supplyBalance[msg.sender][Cube] += amount;
          //update amount of cubes minted
          cubesMinted += amount;
          // update amount of just CUBES PURCHASED
          cubesPurchased += amount;
      }

      function mintOneOfEach() external onlyOwner {
        for (uint256 i = 1; i <= 27; i++) {
         _mint(msg.sender, i, _1, "");
          //update amount of cubes minted
          cubesMinted += amount;
          // update amount of just CUBES PURCHASED
          cubesPurchased += amount;
        }
      }

     
      function claim() public {
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
              if (!tokenIdsClaimed[tokenId]) {
                  amount += 1;
                  tokenIdsClaimed[tokenId] = true;
              }
          }
          // If all the token Ids have been claimed, revert the transaction;
          require(amount > 0, "You have already claimed all the tokens");
          // call the internal function from Openzeppelin's ERC20 contract
          _mint(msg.sender, Cube, amount, "");
          //update msg.sender balance
          supplyBalance[msg.sender][Cube] += amount;
          //update amount of cubes minted
          cubesMinted += amount;
          cubesClaimed += amount;
      }

    /*----adding in random reward system -----*/
    function randomize() private returns(uint256) {
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 25;
        seed = randomNumber + 2; //offset 0 and 1
        return seed;
    }
    /* ----------------------------*/

    function name() public pure returns (string memory) {
        return "NFBeez Cube";
    }

    function symbol() public pure returns (string memory) {
        return "CUBE";
    }  

    // URI overide for number schemes
    function uri(uint256 _tokenId) override public view returns (string memory) {
        return string(
            abi.encodePacked(
                CubeNFT,
                Strings.toString(_tokenId),
                ".json"
            )
        );
    }
    
    function withdraw() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

      // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
  }