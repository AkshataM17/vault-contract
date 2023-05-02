const {ethers} = require("hardhat");

async function main(){

  const vaultContract = await ethers.getContractFactory("Vault");

  const deployVaultContract = await vaultContract.deploy();

  await deployVaultContract.deployed();

  console.log("vault contract address is:", deployVaultContract.address);
}

main().then(() => process.exit(0))
.catch((err) => {
  console.error(err);
  process.exit(1);
})




