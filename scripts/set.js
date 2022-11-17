let signer = {
    "owner": null,
    "user1": null,
    "fee": null
}

let contract = {
    "token": null,
    "keepToken": null
}

async function set() {
    [signer.owner, signer.user1, signer.fee] = await ethers.getSigners();

    let balanceOfOwner = await signer.owner.getBalance() / (10 ** 18);
    let balanceOfUser1 = await signer.user1.getBalance() / (10 ** 18);
    let balanceOfFee = await signer.fee.getBalance() / (10 ** 18);

    console.log("Owner:\t", signer.owner.address, `(${balanceOfOwner} ETH)`);
    console.log("User1:\t", signer.user1.address, `(${balanceOfUser1} ETH)`);
    console.log("Fee:\t", signer.fee.address, `(${balanceOfFee} ETH)`);
}

async function attach() {
    const address = require("../address");

    process.stdout.write("Attach Token");
    contract.token = await ethers.getContractAt("TestERC20", address.Token);
    console.log(" - complete");

    process.stdout.write("Attach KeepToken");
    contract.keepToken = await ethers.getContractAt("KeepERC20", address.KeepToken);
    console.log(" - complete");
}

module.exports = {
    signer,
    contract,
    set,
    attach
}
