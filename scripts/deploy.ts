import { ethers } from "hardhat";

async function main() {
  const TOKEN_URIS = [
    "https://ipfs.io/ipfs/bafkreibc6v4qf5sgyhaqtl5xmtsyhrgce5fw4enj7jydlykiu3ecdr7p5i",
    "https://ipfs.io/ipfs/bafkreihbxllhzlsv75oqin5dyvzfszix26m46rvn2oo7naxevhrjdadtxa",
    "https://ipfs.io/ipfs/bafkreigyjhi6jb4tb7gwfzfol7xtgmgfahprkouzpfyfhc23b4ublmlm3i",
    "https://ipfs.io/ipfs/bafkreifvgb6tp5geenvuiltzs6yymzbeduepyfiw6i4x5qw3h3jkkbnvy4",
    "https://ipfs.io/ipfs/bafkreiaxebe3flauj2tmqc26kfklnaqsxkoroyxjy2ktgtc3wbioxc5u54",
    "https://ipfs.io/ipfs/bafkreiabmduw7y6qmg2c5ltud4sdlwrlnjbqonbqmzcaqb42vjlbqriqkm",
    "https://ipfs.io/ipfs/bafkreifadfigakb6ibxmy5btc5eaq3ynpfmska2wg3btrauwfmxtgkvkae",
    "https://ipfs.io/ipfs/bafkreicbyl5tj7fx73o77lwuredghf27vgq7wfvcr3epxtckbnp2b6fjxi"
  ];

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const GazeBreakerNFT = await ethers.getContractFactory("GazeBreakerNFT");
  const nft = await GazeBreakerNFT.deploy(TOKEN_URIS);
  await nft.waitForDeployment();
  console.log("Contract deployed to:", nft.target);
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
