import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const Asset1Module = buildModule("Asset1Module", (m) => {
  const users = m.getParameter("users", [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  ]);
  const Asset1Contract = m.contract("Asset1", [users]);
  return { Asset1Contract };
});

export const Asset2Module = buildModule("Asset2Module", (m) => {
  const users = m.getParameter("users", [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  ]);
  const Asset2Contract = m.contract("Asset2", [users]);
  return { Asset2Contract };
});
