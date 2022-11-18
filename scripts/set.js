let signer = {
    "owner": null,
    "user1": null,
    "user2": null,
    "fee": null
}

let contract = {
    "token": null,
    "keepTokenFactory": null,
    "keepToken": null
}

async function set() {
    [signer.owner, signer.user1, signer.user2, signer.fee] = await ethers.getSigners();

    let balanceOfOwner = await signer.owner.getBalance() / (10 ** 18);
    let balanceOfUser1 = await signer.user1.getBalance() / (10 ** 18);
    let balanceOfUser2 = await signer.user2.getBalance() / (10 ** 18);
    let balanceOfFee = await signer.fee.getBalance() / (10 ** 18);

    console.log("Owner:\t", signer.owner.address, `(${balanceOfOwner} ETH)`);
    console.log("User1:\t", signer.user1.address, `(${balanceOfUser1} ETH)`);
    console.log("User2:\t", signer.user2.address, `(${balanceOfUser2} ETH)`);
    console.log("Fee:\t", signer.fee.address, `(${balanceOfFee} ETH)`);
}

async function attach() {
    const address = require("../address");

    process.stdout.write("Attach Token");
    contract.token = await ethers.getContractAt("TestERC20", address.Token);
    console.log(" - complete");

    process.stdout.write("Attach KeepTokenFactory");
    contract.keepTokenFactory = await ethers.getContractAt("KeepERC20Factory", address.keepTokenFactory);
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
