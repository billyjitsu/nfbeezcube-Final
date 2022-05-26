const hre = require("hardhat");

async function main() {

  const Web3 = await hre.ethers.getContractFactory("MyToken");
  const web3 = await Web3.deploy();

  await web3.deployed();

  console.log("Template Contract deployed to:", web3.address);
  const receipt = await web3.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);


  const CUBE = await hre.ethers.getContractFactory("BeezCube");
  const cube = await CUBE.deploy(web3.address);

  await cube.deployed();

  console.log("Template Contract deployed to:", cube.address);
  const receipt2 = await cube.deployTransaction.wait();
  console.log("gasUsed:" , receipt.gasUsed);


  ////
  [owner, addr1, addr2, _] = await ethers.getSigners();
  let addy = await cube.address
  
  console.log("address", addy);
  
  /*
  for(let i = 0; i < 100; i++) {
    let txnCube = await cube.mint(1);
  }
  */
  let txnCube = await cube.mint(11);

  /*
  // break open individually
  for(let i = 0; i < 20; i++) {
    let txnbreak = await cube.breakOpen();
  }
  */
 
  let txnBulk = await cube.bulkBreakOpen();

  let txnMintAll = await cube.mintOneOfEach();

   let txnCreateDAO = await cube.createDAOCube();

  for(let i = 0; i < 28; i++) {
  let txnSupply = await cube.totalSupply(i);
  console.log("total supply of", i, ":", txnSupply);
  }


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
