const hre = require("hardhat");
const fs = require('fs');
const { signer, contract, set } = require('./set');

async function deploy() {
  process.stdout.write("Deploy Token");
  const Token = await hre.ethers.getContractFactory("TestERC20");
  contract.token = await Token.deploy();
  await contract.token.deployed();
  console.log(":\t\t", contract.token.address);

  process.stdout.write("Deploy KeepToken");
  const KeepToken = await hre.ethers.getContractFactory("KeepERC20");
  contract.keepToken = await KeepToken.deploy(contract.token.address, 5, signer.fee.address);
  await contract.keepToken.deployed();
  console.log(":\t", contract.keepToken.address);

  fs.writeFileSync("address.json", JSON.stringify({
    "Owner": signer.owner.address,
    "User1": signer.user1.address,
    "Fee": signer.fee.address,
    "Token": contract.token.address,
    "KeepToken": contract.keepToken.address
  }, null, 4));
}

async function main() {
  console.log("\n<Set>");
  await set();

  console.log("\n<Deploy>");
  await deploy();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
