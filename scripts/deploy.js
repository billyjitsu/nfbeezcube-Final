const hre = require("hardhat");

async function main() {

  //variables
 // const royalty = "500";
 
  const NFBeez = "0x0f37B8101f014cf9806799b7159b32c010397d55";
  const airnodeRrp = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; // Rinkeby & Gnosis
  const royaltyWallet = "0x49284a18822eE0d75fD928e5e0fC5a46C9213D96";
  const ipfsPath = "https://nfbeez.mypinata.cloud/ipfs/QmS6Ce2iFyaxvyyUzTBnvPNysR5TrsrPGWdMjDWEt9wwK3/";
 // const artist = "0x9263bFf6ACCb60E83254E95220e7637465298171";   // Ata Address
  const beezSafe = "0x2BdE4a5458452307aD080e09D8fB5c74FA71d208";  // NFBeez Safe - safe on rinkeby
//  const donation = "0x6961367Ef8b92c1a306a68C87ADD9Eafd09f7787";  // donation 
   const testNFT = "0xfeE366C16aB4E158F324C6BA2D390a5be70b6b96"
  
 
  // const Web3 = await hre.ethers.getContractFactory("MyToken");
  // const web3 = await Web3.deploy();

  // await web3.deployed();

  // console.log("Template Contract deployed to:", web3.address);
  // const receipt = await web3.deployTransaction.wait();
  // console.log("gasUsed:" , receipt.gasUsed);
 

 // const CUBE = await hre.ethers.getContractFactory("BeezCube");
  const CUBE = await hre.ethers.getContractFactory("TestZone");
  //const cube = await CUBE.deploy(web3.address, airnodeRrp, royaltyWallet, ipfsPath, beezSafe);
  const cube = await CUBE.deploy(testNFT, airnodeRrp, royaltyWallet, ipfsPath, beezSafe);

  await cube.deployed();

  console.log("BeezCube Contract deployed to:", cube.address);
  const receipt2 = await cube.deployTransaction.wait();
  console.log("gasUsed:" , receipt2.gasUsed);
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