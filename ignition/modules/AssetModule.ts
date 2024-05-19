import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const Asset1Module = buildModule("Asset1Module", (m) => {
  const users = m.getParameter("users", [
    "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
  ]);
  const Asset1Contract = m.contract("Asset1", [users]);
  return { Asset1Contract };
});

export const Asset2Module = buildModule("Asset2Module", (m) => {
  const users = m.getParameter("users", [
    "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
  ]);
  const Asset2Contract = m.contract("Asset2", [users]);
  return { Asset2Contract };
});
