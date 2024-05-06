import { ignition, ethers } from "hardhat";
import BoomPoolModule from "../ignition/modules/BoomPoolModule";
import DTokenModule from "../ignition/modules/DTokenModule";
import STokenModule from "../ignition/modules/STokenModule";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { assert, expect } from "chai";
import "dotenv/config";

const asset1 = process.env.ASSET1;
const asset2 = process.env.ASSET2;
const asset3 = process.env.ASSET3;
const asset4 = process.env.ASSET4;
const asset5 = process.env.ASSET5;

describe("Boompool", async () => {
  async function deploy() {
    const { BoomPool } = await ignition.deploy(BoomPoolModule);
    const { SToken } = await ignition.deploy(STokenModule);

    return { BoomPool, SToken };
  }
  async function getContract() {
    const fixture = await loadFixture(deploy);
    const BoomPool = fixture.BoomPool;
    const SToken = fixture.SToken;

    return { BoomPool, SToken };
  }

  describe("constructor", async () => {
    it("adminInBothContract", async () => {
      const { BoomPool, SToken } = await getContract();
      const deployer = (await ethers.getSigners())[0];
      const poolAdmin = await BoomPool.getAdmin();
      const sTokenAdmind = await SToken.getAdmin();
      const pool = await SToken.getPool();
      assert.equal(poolAdmin, deployer.address);
      assert.equal(sTokenAdmind, deployer.address);
      assert.equal(pool, await BoomPool.getAddress());
    });
  });
});
