import DiamondAbi from "./ABIs/diamond.json" assert { type: "json" };
import { PublicKey, Connection, SYSVAR_CLOCK_PUBKEY } from "@solana/web3.js";
import {
  Contract,
  JsonRpcApiProvider,
  JsonRpcProvider,
  Wallet,
  keccak256,
  verifyMessage,
  zeroPadBytes,
} from "ethers";
import { addresses } from "@mayanfinance/swap-sdk";
import dotenv from "dotenv";
dotenv.config();

export function solanaAddressToHex(address) {
  return zeroPadBytes(new PublicKey(address).toBytes(), 32);
}

// const solAddress = "Gqjr8NdrykXUrpPFzZDzsHDNK3NUd3gNhXzgzAvXK2Nh";

// const ATAs_OWNER = "o2YiH9UfqjfeT39eKasWMtUs9mYMBM9EyuzSFptYa8j";

// const programId = new PublicKey(addresses.TOKEN_PROGRAM_ID);

// const associatedTokenProgramId = new PublicKey(
//   addresses.ASSOCIATED_TOKEN_PROGRAM_ID
// );

// const mint = new PublicKey("HAxCJjnmgkdXhwZYeJiUvBgm4NdQvqhGJCS3KxCnCxWs");
// // 0xf047a090a93150a8d5474f4f2a7a3f45988742a726238514ef23de4ce60cd7a8

// const owner = new PublicKey(ATAs_OWNER);

// const [address] = PublicKey.findProgramAddressSync(
//   [owner.toBuffer(), programId.toBuffer(), mint.toBuffer()],
//   associatedTokenProgramId
// );

// console.log("ATA", address)

const provider = new JsonRpcProvider(process.env.ARBITRUM_RPC_URL);
const signer = new Wallet(process.env.PRIVATE_KEY, provider);

const diamond = new Contract(
  "0x4B2A962eDdf1a3aF48Aa8648621e9Fb7670809c8",
  DiamondAbi,
  signer
);

let inboundPayload = await diamond.buildDepositPayload(
  "0xc0388cBC4398856c06628dca4B25857591BD34A4",
  [
    "0xc6fa7af3bedbad3a3d65f36aabc97431b1bbe4c2d2f6e0e47ca60203452f5d61",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
    "0x1111111111111111111111111111111111111111111111111111111111111111",
  ],
  1000000
);

const msgHash = keccak256(inboundPayload[2]);

let signature = signer.signingKey.sign(msgHash);
console.log("Sig", signature.serialized);

const usdcContract = new Contract(
  "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",
  ["function approve(address spender, uint256 amount)"],
  signer
);

await usdcContract.approve(
  await diamond.getAddress(),
  100004012481042129104141280412412421414241n
);

console.log("INbound payload", inboundPayload);

const res = await diamond.executeHxroPayloadWithTokens(
  Array.from(inboundPayload),
  signature.serialized, {
    gasLimit: 3500000
  }
);
await res.wait();

console.log(`TX Done: https://arbiscan.io/tx/${res.hash}`);

// console.log(solanaAddressToHex("HAxCJjnmgkdXhwZYeJiUvBgm4NdQvqhGJCS3KxCnCxWs"));
