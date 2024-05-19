import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const PriceFeedForAsset = buildModule("PriceFeed", (m) => {
  const decimals = m.getParameter("_decimals", 18);
  const initialAnswer = m.getParameter("_initialAnswer", 3000);
  const MockV3Aggregator = m.contract("MockV3Aggregator", [
    decimals,
    initialAnswer,
  ]);
  return { MockV3Aggregator };
});

export default PriceFeedForAsset;
