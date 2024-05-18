import { ignition, ethers } from "hardhat";
import {} from "@nomicfoundation/hardhat-ethers/types";
import BoomPoolModule from "../ignition/modules/BoomPoolModule";
import DTokenModule from "../ignition/modules/DTokenModule";
import STokenModule from "../ignition/modules/STokenModule";
import { Asset1Module, Asset2Module } from "../ignition/modules/AssetModule";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { assert, expect } from "chai";
import "dotenv/config";
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";

interface TestEnv {
  deployer: AddressLike;
  boomPool: BaseContract;
}

async function deployPool() {
  const { BoomPool } = await ignition.deploy(BoomPoolModule);

  return BoomPool;
}

const testEnv: TestEnv = {
  deployer: "" as AddressLike,
  boomPool: {} as BaseContract,
};

async function initTestEnv() {
  testEnv.deployer = (await ethers.getSigners())[0];
  testEnv.boomPool = await deployPool();
}

describe("BoomPoolWithdraw", async () => {});
