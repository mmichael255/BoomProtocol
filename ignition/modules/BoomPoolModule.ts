import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BoomPoolModule = buildModule("BoomPoolModule", (m) => {
  const BoomPool = m.contract("BoomPool");
  return { BoomPool };
});

export default BoomPoolModule;
