const hre = require("hardhat");

async function main() {

  //variables
 // const royalty = "500";
 
  const NFBeez = "0x0f37B8101f014cf9806799b7159b32c010397d55"; //NFBeez Gnosis contract address 
  const airnodeRrp = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; //Gnosis
  const royaltyWallet = "0x49284a18822eE0d75fD928e5e0fC5a46C9213D96";
  const ipfsPath = "https://nfbeez.mypinata.cloud/ipfs/QmYnE2aEkEvM6DRQ6zRFTFAw7oZ35PTKkay9cBV97U2SpU/";
  const beezSafe = "0x0fA8e1C23d4af14e94F7F75367a3fA4111b7B047";  // NFBeez Gnosis
   const testNFT = "0xfeE366C16aB4E158F324C6BA2D390a5be70b6b96"  // temp Goerli temp NFT
  
 
  // const Web3 = await hre.ethers.getContractFactory("MyToken");
  // const web3 = await Web3.deploy();

  // await web3.deployed();

  // console.log("Template Contract deployed to:", web3.address);
  // const receipt = await web3.deployTransaction.wait();
  // console.log("gasUsed:" , receipt.gasUsed);
 

 // const CUBE = await hre.ethers.getContractFactory("BeezCube");
  const CUBE = await hre.ethers.getContractFactory("TestZone");
  //const cube = await CUBE.deploy(web3.address, airnodeRrp, royaltyWallet, ipfsPath, beezSafe);
  const cube = await CUBE.deploy(NFBeez, airnodeRrp, royaltyWallet, ipfsPath, beezSafe);

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