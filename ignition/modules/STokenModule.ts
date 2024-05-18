import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import BoomPoolModule from "./BoomPoolModule";

const STokenModule = buildModule("STokenModule", (m) => {
  const SToken = m.contract("SToken");
  // const { BoomPool } = m.useModule(BoomPoolModule);
  // m.call(SToken, "initial", [BoomPool]);
  return { SToken };
});

export default STokenModule;
