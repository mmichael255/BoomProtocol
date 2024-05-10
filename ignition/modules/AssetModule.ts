import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const Asset1Module = buildModule("Asset1Module", (m) => {
  const Asset1Contract = m.contract("Asset1");
  return { Asset1Contract };
});

export const Asset2Module = buildModule("Asset2Module", (m) => {
  const Asset2Contract = m.contract("Asset2");
  return { Asset2Contract };
});
