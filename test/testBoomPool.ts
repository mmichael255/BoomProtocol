import { ignition, ethers } from "hardhat";
import BoomPoolModule from "../ignition/modules/BoomPoolModule";
import DTokenModule from "../ignition/modules/DTokenModule";
import STokenModule from "../ignition/modules/STokenModule";
import { Asset1Module, Asset2Module } from "../ignition/modules/AssetModule";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { assert, expect } from "chai";
import "dotenv/config";

const asset1 = process.env.ASSET1;
const asset2 = process.env.ASSET2;
const asset3 = process.env.ASSET3;
const asset4 = process.env.ASSET4;
const asset5 = process.env.ASSET5;

describe("Boompool", async () => {
  async function deployPool() {
    const { BoomPool } = await ignition.deploy(BoomPoolModule);

    return BoomPool;
  }
  async function deploySToken() {
    const { SToken } = await ignition.deploy(STokenModule);

    return SToken;
  }
  async function deployDToken() {
    const { DToken } = await ignition.deploy(DTokenModule);

    return DToken;
  }
  async function deployAsset() {
    const { Asset1Contract } = await ignition.deploy(Asset1Module);
    const { Asset2Contract } = await ignition.deploy(Asset2Module);
    return { Asset1Contract, Asset2Contract };
  }
  async function getBoomPool() {
    const BoomPool = await loadFixture(deployPool);
    return BoomPool;
  }
  async function getSToken() {
    const SToken = await loadFixture(deploySToken);
    return SToken;
  }
  async function getDToken() {
    const DToken = await loadFixture(deployDToken);
    return DToken;
  }
  async function getAsset() {
    const fixture = await loadFixture(deployAsset);
    return fixture;
  }

  describe("constructor", async () => {
    it("adminInBothContract", async () => {
      const BoomPool = await getBoomPool();
      const SToken = await getSToken();
      const deployer = (await ethers.getSigners())[0];
      const poolAdmin = await BoomPool.getAdmin();
      const sTokenAdmin = await SToken.getAdmin();
      const pool = await SToken.getPool();
      assert.equal(poolAdmin, deployer.address);
      assert.equal(sTokenAdmin, deployer.address);
      assert.equal(pool, await BoomPool.getAddress());
    });
  });
  describe("deposit", async () => {
    it("addAsset", async () => {
      const BoomPool = await getBoomPool();
      await BoomPool.addAssert(asset1);
      await BoomPool.addAssert(asset2);

      const asset1FromList = await BoomPool.getAssetFromList(0);
      const asset2FromList = await BoomPool.getAssetFromList(1);

      const asset1Id = (await BoomPool.getAssetInfo(asset1)).id;
      const asset2Id = (await BoomPool.getAssetInfo(asset2)).id;

      assert.equal(asset1FromList, asset1);
      assert.equal(asset2FromList, asset2);
      assert.equal(asset1Id, 0);
      assert.equal(asset2Id, 1);
    });
    it("initAsset", async () => {
      const BoomPool = await getBoomPool();
      const STokenForAsset1 = await getSToken();
      const DTokenForAsset1 = await getDToken();
      await BoomPool.addAssert(asset1);
      const assetIndex = 1;
      await BoomPool.initAssert(
        asset1,
        assetIndex,
        STokenForAsset1,
        DTokenForAsset1
      );

      const asset1Info = await BoomPool.getAssetInfo(asset1);

      assert.equal(asset1Info.id, 0);
      assert.equal(asset1Info.isActive, true);
      assert.equal(asset1Info.assetIndex, assetIndex);
      assert.equal(
        asset1Info.sTokenAddress,
        await STokenForAsset1.getAddress()
      );
      assert.equal(
        asset1Info.dTokenAddress,
        await DTokenForAsset1.getAddress()
      );
    });
    it("depositToPool", async () => {
      const BoomPool = await getBoomPool();
      const STokenForAsset1 = await getSToken();
    });
  });
});
