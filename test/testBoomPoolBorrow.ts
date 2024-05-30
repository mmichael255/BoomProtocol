import { assert, expect } from "chai";
import "dotenv/config";
import { testEnv, initTestEnv } from "./setUpEnv";
import { it } from "mocha";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

const decimals = 18;
const assetIndex = 1;
const interestRate = 0;
const allowedAmount = ethers.parseEther("1");
let userDepositedAsset1: Signer = testEnv.users[1];
let userDepositedAsset2: Signer = testEnv.users[6];

describe("BoomPoolBorrow", async () => {
  before(async () => {
    await initTestEnv();
    const { boomPool, assets, users, sTokens, dTokens, priceFeeds } = testEnv;
    await boomPool.addAssert(assets[0]);
    await boomPool.addAssert(assets[1]);

    userDepositedAsset1 = users[1];
    userDepositedAsset2 = users[6];
    await boomPool.initAssert(
      assets[0],
      priceFeeds[0],
      decimals,
      assetIndex,
      interestRate,
      sTokens[0],
      dTokens[0]
    );
    await boomPool.initAssert(
      assets[1],
      priceFeeds[1],
      decimals,
      assetIndex * 2,
      interestRate,
      sTokens[1],
      dTokens[1]
    );
    const user1Asset1 = assets[0].connect(userDepositedAsset1);
    const user2Asset2 = assets[1].connect(userDepositedAsset2);

    user1Asset1.approve(boomPool, allowedAmount);
    user2Asset2.approve(boomPool, BigInt(3) * allowedAmount);

    const user1Pool = boomPool.connect(userDepositedAsset1);
    const user2Pool = boomPool.connect(userDepositedAsset2);

    await user1Pool.deposit(assets[0], allowedAmount);
    await user2Pool.deposit(assets[1], BigInt(3) * allowedAmount);
  });
  it("testInitEnv", async () => {
    const { boomPool, assets, users, sTokens, dTokens, priceFeeds } = testEnv;
    //get user balance in assets
    console.log(
      `asset1 user1 balance: ${await assets[0].balanceOf(userDepositedAsset1)}`
    );
    console.log(
      `asset2 user2 balance: ${await assets[1].balanceOf(userDepositedAsset2)}`
    );
    console.log(
      `asset1 stoken1 balance: ${await assets[0].balanceOf(sTokens[0])}`
    );
    console.log(
      `asset2 stoken2 balance: ${await assets[1].balanceOf(sTokens[1])}`
    );
    console.log(
      `stoken1 user1 balance: ${await sTokens[0].balanceOf(
        userDepositedAsset1
      )}`
    );
    console.log(
      `stoken2 user2 balance: ${await sTokens[1].balanceOf(
        userDepositedAsset2
      )}`
    );
    // console.log(await boomPool.getAssetInfo(assets[0]));
    // console.log(await boomPool.getAssetInfo(assets[1]));
  });
});
