import { ignition, ethers } from "hardhat";
import BoomPoolModule from "../ignition/modules/BoomPoolModule";
import DTokenModule from "../ignition/modules/DTokenModule";
import STokenModule from "../ignition/modules/STokenModule";
import MockPriceFeedModule from "../ignition/modules/MockPriceFeedModule";
import { Asset1Module, Asset2Module } from "../ignition/modules/AssetModule";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type {
  Signer,
  BaseContract,
  Contract,
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
async function deployPriceFeed() {
  const { MockV3Aggregator } = await ignition.deploy(MockPriceFeedModule);

  return MockV3Aggregator;
}
async function deployAssetContract() {
  const users = await ethers.getSigners();
  const usersForAsset1: string[] = [];
  const usersForAsset2: string[] = [];
  for (let i = 1; i < users.length; i++) {
    if (i < 4) {
      usersForAsset1.push(users[i].address);
    }
    if (i > 6) {
      usersForAsset2.push(users[i].address);
    }
  }
  const { Asset1Contract } = await ignition.deploy(Asset1Module, {
    parameters: { Asset1: { users: usersForAsset1 } },
  });
  const { Asset2Contract } = await ignition.deploy(Asset2Module, {
    parameters: { Asset2: { users: usersForAsset2 } },
  });
  return { Asset1Contract, Asset2Contract };
}
async function getBoomPool() {
  const BoomPool = await loadFixture(deployPool);
  return BoomPool;
}
async function getSToken(poolAddr: string) {
  const SToken = await loadFixture(deploySToken);
  await SToken.initial(poolAddr);
  return SToken;
}
async function getDToken() {
  const DToken = await loadFixture(deployDToken);
  return DToken;
}
async function getPriceFeed() {
  const MockV3Aggregator = await loadFixture(deployPriceFeed);
  return MockV3Aggregator;
}
async function getAssetContract() {
  const fixture = await loadFixture(deployAssetContract);
  return fixture;
}

export interface TestEnv {
  deployer: Signer;
  users: Signer[];
  boomPool: Contract;
  assets: Contract[];
  sTokens: Contract[];
  dTokens: Contract[];
  priceFeeds: Contract[];
}

export const testEnv: TestEnv = {
  deployer: {} as Signer,
  users: [] as Signer[],
  boomPool: {} as Contract,
  assets: [] as Contract[],
  sTokens: [] as Contract[],
  dTokens: [] as Contract[],
  priceFeeds: [] as Contract[],
};

export async function initTestEnv() {
  testEnv.deployer = (await ethers.getSigners())[0];
  testEnv.users = await ethers.getSigners();
  testEnv.boomPool = await getBoomPool();
  const { Asset1Contract, Asset2Contract } = await getAssetContract();
  testEnv.assets.push(Asset1Contract, Asset2Contract);
  for (let i = 0; i < testEnv.assets.length; i++) {
    testEnv.sTokens.push(await deploySToken());
    await testEnv.sTokens[0].initial(await testEnv.boomPool.getAddress());
    testEnv.dTokens.push(await deployDToken());
    testEnv.priceFeeds.push(await deployPriceFeed());
  }
}
