const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

// [address, amount in wei]. 1000 XVII = 1000 * 10^18
const values = [

    ["0x41F213b01Dc6FaF46AFeFbE2d5ce2c9E589ca072", "1000000000000000000000"],

    ["0x1111111111111111111111111111111111111111", "500000000000000000000"], 

    ["0x2222222222222222222222222222222222222222", "250000000000000000000"],

];

const tree = StandardMerkleTree.of(values, ["address", "uint256"]);
console.log("Root:", tree.root);
fs.writeFileSync("tree.json", JSON.stringify(tree.dump(), null, 2));

for (const [i, v] of tree.entries()) {
    console.log(v[0], "proof:", JSON.stringify(tree.getProof(i)));
}