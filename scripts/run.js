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
  
  for(let i = 0; i < 550; i++) {
  let txn = await cube.mint(1)
  await txn.wait()
  }
 // let hydroBal = await chem.supplyBalance(owner.address, 1);
//  console.log("Hydrogen balance:", hydroBal)
//  let oxyBal = await chem.supplyBalance(owner.address, 8);
//  console.log("Oxygen balance:", oxyBal)

 
}



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
