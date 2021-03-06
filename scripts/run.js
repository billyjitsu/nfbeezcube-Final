const hre = require("hardhat");

async function main() {

  const airnodeRrp = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; // Rinkeby & Gnosis
  const royaltyWallet = "0x49284a18822eE0d75fD928e5e0fC5a46C9213D96";
  const ipfsPath = "https://nfbeez.mypinata.cloud/ipfs/QmbrPWpDqrfKKaCw9XVvroUb3cS7c8LYP3jvAP6ZhQDekC/";
  

  const Web3 = await hre.ethers.getContractFactory("MyToken");
  const web3 = await Web3.deploy();
  await web3.deployed();

  console.log("Template Contract deployed to:", web3.address);
  const receipt = await web3.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);


 // const CUBE = await hre.ethers.getContractFactory("BeezCube");
  const CUBE = await hre.ethers.getContractFactory("TestZone");
  const cube = await CUBE.deploy(web3.address, airnodeRrp, royaltyWallet, ipfsPath);
  await cube.deployed();

  console.log("Template Contract deployed to:", cube.address);
  const receipt2 = await cube.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);


  ////
  [owner, addr1, addr2, _] = await ethers.getSigners();
  let addy = await cube.address
  
  //console.log("address", addy);

  // NFT Claim
  
  
   for(let i = 0; i < 5; i++) {
     let txnMintNFT = await web3.safeMint();
     await txnMintNFT.wait()
   }
   console.log("Minted tokens")
  // console.log("going to pause")
 // let txnPauseNFT = await cube.togglePause();
  //console.log("status", txnPauseNFT)
  
  let txnClaim = await cube.claim();
  console.log("Claim Cubes")

 /* 
  for(let i = 0; i < 2474; i++) {
    let txnCube = await cube.mint(1);
  }
  
 // let txnCube = await cube.mint(20);

  /*
  // break open individually
  for(let i = 0; i < 100; i++) {
    let txnbreak = await cube.breakOpen();
  }
  */
  
 
 // let txnBulk = await cube.bulkBreakOpen();

 // let txnMintAll = await cube.mintOneOfEach();

 //  let txnCreateDAO = await cube.createDAOCube();

 // for(let i = 1; i < 28; i++) {
 // let txnSupply = await cube.totalSupply(i);
 // console.log("total supply of", i, ":", txnSupply);
 // }


 // let txn = await cube.mintOneOfEach()
 // await txn.wait()

 
}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
