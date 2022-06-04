const hre = require("hardhat");

async function main() {

  //variables
 // const royalty = "500";
 

  const airnodeRrp = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; // Rinkeby
  const royaltyWallet = "0x49284a18822eE0d75fD928e5e0fC5a46C9213D96";
  const ipfsPath = "https://nfbeez.mypinata.cloud/ipfs/QmRavqAonhSrsckz1T4zBb9eNu4Xk554FBY5kvhCfTjtb6/";
  
  const Web3 = await hre.ethers.getContractFactory("MyToken");
  const web3 = await Web3.deploy();

  await web3.deployed();

  console.log("Template Contract deployed to:", web3.address);
  const receipt = await web3.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);


  const CUBE = await hre.ethers.getContractFactory("BeezCube");
  const cube = await CUBE.deploy(web3.address, airnodeRrp, royaltyWallet, ipfsPath);

  await cube.deployed();

  console.log("BeezCube Contract deployed to:", cube.address);
  const receipt2 = await cube.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// After the deployment
/*
 setRequestParameters
 _airnode address:  0x9d3C147cA16DB954873A498e0af5852AB39139f2
 _endpointIdUINT256: 0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78
 _sponsor - is a mixutre of the formula and my deployed address

 FUND the SPONSOR WALLET


*/