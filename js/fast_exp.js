const fs = require("fs");
const bytes = fs.readFileSync(__dirname + "/../wasm/fast_exp.wasm");

let memory = new WebAssembly.Memory({ initial: 2 });
let impObj = { env: { mem: memory } };

const NUMNUMS = 4;
const START = 0;
const v128_SIZE = 4;
let vals = new Float32Array(memory.buffer, START, NUMNUMS);
const V = 0
for (var i = START; i < NUMNUMS; i++) {
    //vals[i] = Math.random();
    vals[i] = i + V;
}
(async () => {
    //console.log(vals);
    let obj = await WebAssembly.instantiate(
        new Uint8Array(bytes), impObj);
    const { fastexp_v128, fastexp } = obj.instance.exports;

    for (var i = START; i < NUMNUMS; i++) {vals[i] = i + V;}
    vals[1] = -88; // Good, protections work -> 0
    vals[3] = 100; // Good, protections work -> +Inf
    console.log("Original Schraudolph's algorithm:");
    console.log(vals);
    fastexp_v128(START, NUMNUMS * v128_SIZE);
    console.log(vals);

    for (var i = START; i < NUMNUMS; i++) {vals[i] = i + V;}
    vals[1] = -88; // Good, protections work -> 0
    vals[3] = 100; // Good, protections work -> +Inf
    console.log("wasm-fun algorithm:");
    console.log(vals);
    for (var i = START; i < NUMNUMS; i++) {console.log(fastexp(vals[i]));}
    console.log(vals);

})();
