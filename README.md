# KeepERC20

TBD

---

# Requirements

```bash
$ npm install
```

# Set `.env`

and/or `.env.test` for test environment.

Now we can use pre-defined values as environment variable, with a prefix `dotenv -e <ENV> --`. For example, `dotenv -e .env.test --`.

# Run Node

```bash
$ dotenv -e .env.test -- npx hardhat node --network hardhat
```

# Deploy

```bash
$ dotenv -e .env -- npx hardhat run scripts/deploy.js --network localhost
```

<!--
### Console
```bash
# View
$ await ethers.provider.getBlockNumber();
$ await ethers.provider.getBlock();

# Mining
$ await network.provider.send("evm_setAutomine", [false]);
$ await network.provider.send("evm_setIntervalMining", [1000]);

# Increase Time & Block
$ await network.provider.send("evm_increaseTime", [10000]);
$ await ethers.provider.send("hardhat_mine", [ethers.utils.hexValue(10)]);

# Balance
$ await ethers.provider.getBalance("0xa29A12B879bCC89faE72687e09Da3c3995B91fe5")
```
-->
