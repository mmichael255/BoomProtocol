import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DTokenModule = buildModule("DTokenModule", (m) => {
  const DToken = m.contract("BoomPool");
  return { DToken };
});

export default DTokenModule;
