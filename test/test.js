const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Cube", function () {

  let airnodeRrp = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; // Rinkeby & Gnosis
  let royaltyWallet = "0x49284a18822eE0d75fD928e5e0fC5a46C9213D96";
  let ipfsPath = "https://nfbeez.mypinata.cloud/ipfs/QmbrPWpDqrfKKaCw9XVvroUb3cS7c8LYP3jvAP6ZhQDekC/";
  let artist = "0x9263bFf6ACCb60E83254E95220e7637465298171";   // Ata Address
  let beezSafe = "0x2BdE4a5458452307aD080e09D8fB5c74FA71d208";  // NFBeez Safe - safe on rinkeby
  let donation = "0x6961367Ef8b92c1a306a68C87ADD9Eafd09f7787";  // donation 

  let Web3, web3, CUBE, cube,  owner, addr1, addr2;
  
  beforeEach(async () => {
     Web3 = await hre.ethers.getContractFactory("MyToken");
     web3 = await Web3.deploy();
    await web3.deployed();
    console.log("MyToken Contract deployed to:", web3.address);
    
    CUBE = await hre.ethers.getContractFactory("TestZone");
    console.log('pulled contract');
    console.log("Variables:", web3.address, airnodeRrp, royaltyWallet, ipfsPath, artist, beezSafe,donation);
    cube = await CUBE.deploy(web3.address, airnodeRrp, royaltyWallet, ipfsPath, artist, beezSafe, donation);
    console.log("about to deploy");
    await cube.deployed();
   console.log("Cube Contract deployed to:", cube.address);

    [owner, addr1, addr2, _] = await ethers.getSigners();
  })


  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      expect(await web3.owner()).to.equal(owner.address)
    })
  })
  

  /*
  it("Should mint some NFTs", async function () {
    console.log("about to start");
    for(let i = 0; i < 5; i++) {
      let txnMintNFT = await web3.safeMint();
      await txnMintNFT.wait()
    }
    console.log("finished");
    expect(await web3.balanceOf()).to.equal(5);
  });
  */
});
