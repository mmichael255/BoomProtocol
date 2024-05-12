import { ignition, ethers } from "hardhat";
import BoomPoolModule from "../ignition/modules/BoomPoolModule";
import DTokenModule from "../ignition/modules/DTokenModule";
import STokenModule from "../ignition/modules/STokenModule";
import { Asset1Module, Asset2Module } from "../ignition/modules/AssetModule";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { assert, expect } from "chai";
import "dotenv/config";

const asset1Oracle = process.env.ASSET1;
const asset2Oracle = process.env.ASSET2;
const asset3Oracle = process.env.ASSET3;
const asset4Oracle = process.env.ASSET4;
const asset5Oracle = process.env.ASSET5;

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
  async function deployAssetContract() {
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
  async function getAssetContract() {
    const fixture = await loadFixture(deployAssetContract);
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
      await BoomPool.addAssert(asset1Oracle);
      await BoomPool.addAssert(asset2Oracle);

      const asset1FromList = await BoomPool.getAssetFromList(0);
      const asset2FromList = await BoomPool.getAssetFromList(1);

      const asset1Id = (await BoomPool.getAssetInfo(asset1Oracle)).id;
      const asset2Id = (await BoomPool.getAssetInfo(asset2Oracle)).id;

      assert.equal(asset1FromList, asset1Oracle);
      assert.equal(asset2FromList, asset2Oracle);
      assert.equal(asset1Id, 0);
      assert.equal(asset2Id, 1);
    });
    it("initAsset", async () => {
      const BoomPool = await getBoomPool();
      const STokenForAsset1 = await getSToken();
      const DTokenForAsset1 = await getDToken();
      const Asset1Contract = (await getAssetContract()).Asset1Contract;
      await BoomPool.addAssert(Asset1Contract);
      const assetIndex = 1;
      await BoomPool.initAssert(
        Asset1Contract,
        asset1Oracle,
        assetIndex,
        STokenForAsset1,
        DTokenForAsset1
      );

      const asset1Info = await BoomPool.getAssetInfo(Asset1Contract);

      assert.equal(asset1Info.id, 0);
      assert.equal(asset1Info.isActive, true);
      assert.equal(asset1Info.priceFeed, asset1Oracle);
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
    it("deployAssetContracts", async () => {
      const AssetContracts = await getAssetContract();
      const deployer = (await ethers.getSigners())[0];
      const deployer1Balance = await AssetContracts.Asset1Contract.balanceOf(
        deployer
      );
      const totalSupply1 = await AssetContracts.Asset1Contract.totalSupply();
      const deployer2Balance = await AssetContracts.Asset2Contract.balanceOf(
        deployer
      );
      const totalSupply2 = await AssetContracts.Asset2Contract.totalSupply();
      const supply = ethers.parseEther("100");
      assert.equal(deployer1Balance, supply);
      assert.equal(totalSupply1, supply);
      assert.equal(deployer2Balance, supply);
      assert.equal(totalSupply2, supply);
    });
    it("depositToPool", async () => {
      const BoomPool = await getBoomPool();
      const AssetContracts = await getAssetContract();
      const user = (await ethers.getSigners())[0];

      await BoomPool.addAssert(AssetContracts.Asset1Contract);
      const STokenForAsset1 = await getSToken();
      const DTokenForAsset1 = await getDToken();

      const assetIndex = 1;
      const amount = ethers.parseEther("10");

      await BoomPool.initAssert(
        AssetContracts.Asset1Contract,
        asset1Oracle,
        assetIndex,
        STokenForAsset1,
        DTokenForAsset1
      );

      console.log(`poolAddr:${await BoomPool.getAddress()}`);
      console.log(`STokenAddr:${await STokenForAsset1.getAddress()}`);

      const userAsset1Contract = AssetContracts.Asset1Contract.connect(user);

      await userAsset1Contract.approve(BoomPool, amount);
      const allowance = await userAsset1Contract.allowance(user, BoomPool);
      console.log(`Allowance:${allowance}`);
      const userPoolContract = BoomPool.connect(user);
      await userPoolContract.deposit(AssetContracts.Asset1Contract, amount);
      const mintSTokenToUser = Number(amount) / assetIndex;
      const userSToken1Balance = await STokenForAsset1.balanceOf(user);
      const poolAsset1Balance = await AssetContracts.Asset1Contract.balanceOf(
        STokenForAsset1
      );

      assert.equal(userSToken1Balance, mintSTokenToUser);
      assert.equal(poolAsset1Balance, amount);
    });
  });
});
