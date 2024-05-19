import { assert, expect } from "chai";
import "dotenv/config";
import { testEnv, initTestEnv } from "./setUpEnv";
import { it } from "mocha";
import { ethers } from "hardhat";

const decimals = 18;
const assetIndex = 1;
const depolyAmount = ethers.parseEther("10");

describe("BoomPoolWithdraw", async () => {
  before(async () => {
    await initTestEnv();
    const { boomPool, assets, users, sTokens, dTokens, priceFeeds } = testEnv;
    await boomPool.addAssert(assets[0]);
    await boomPool.addAssert(assets[1]);

    await boomPool.initAssert(
      assets[0],
      priceFeeds[0],
      decimals,
      assetIndex,
      sTokens[0],
      dTokens[0]
    );
    await boomPool.initAssert(
      assets[1],
      priceFeeds[1],
      decimals,
      assetIndex,
      sTokens[1],
      dTokens[1]
    );
  });
  it("testEnv", async () => {
    const { boomPool, assets, users, sTokens, dTokens, priceFeeds } = testEnv;
    console.log(await boomPool.getAssetInfo(assets[0]));
    console.log(await boomPool.getAssetInfo(assets[1]));
  });
});