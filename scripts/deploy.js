const hre = require("hardhat");
const fs = require('fs');
const { signer, contract, set } = require('./set');

async function deploy() {
  process.stdout.write("Deploy Token");
  const Token = await hre.ethers.getContractFactory("TestERC20");
  contract.token = await Token.deploy();
  await contract.token.deployed();
  console.log(":\t\t", contract.token.address);

  process.stdout.write("Deploy Factory");
  const KeepTokenFactory = await hre.ethers.getContractFactory("KeepERC20Factory");
  contract.keepTokenFactory = await KeepTokenFactory.deploy(
    5,
    10,
    signer.fee.address
  );
  await contract.keepTokenFactory.deployed();
  console.log(":\t\t", contract.keepTokenFactory.address);

  process.stdout.write("Deploy KeepToken");
  const txRes = await contract.keepTokenFactory.createKeep(
    contract.token.address
  );
  await txRes.wait();
  const keepTokenAddress = await contract.keepTokenFactory.keepOf(contract.token.address);
  contract.keepToken = await ethers.getContractAt("KeepERC20", keepTokenAddress);
  console.log(":\t", contract.keepToken.address);

  process.stdout.write("Deploy Encoder");
  const Encoder = await hre.ethers.getContractFactory("Encoder");
  contract.encoder = await Encoder.deploy();
  await contract.encoder.deployed();
  console.log(":\t\t", contract.encoder.address);

  fs.writeFileSync("address.json", JSON.stringify({
    "Owner": signer.owner.address,
    "User1": signer.user1.address,
    "User2": signer.user2.address,
    "Fee": signer.fee.address,
    "Token": contract.token.address,
    "KeepTokenFactory": contract.keepTokenFactory.address,
    "KeepToken": contract.keepToken.address,
    "Encoder": contract.encoder.address
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
