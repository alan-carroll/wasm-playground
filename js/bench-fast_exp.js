const fs = require("fs");
const bytes = fs.readFileSync(__dirname + "/../wasm/fast_exp.wasm");

let memory = new WebAssembly.Memory({ initial: 2 });
let impObj = { env: { mem: memory } };

const NUMNUMS = 20000;
const RUNS = 10000;
const START = 0;
const v128_SIZE = 4;
let vals = new Float32Array(memory.buffer, START, NUMNUMS);

let start = new Float64Array(RUNS);
let end = new Float64Array(RUNS);
let diff = new Float64Array(RUNS);

(async () => {
    let obj = await WebAssembly.instantiate(
        new Uint8Array(bytes), impObj);
    const { fastexp_v128, fastexp } = obj.instance.exports;

    // Original exp test
    for (var i = START; i < NUMNUMS; i++) {vals[i] = Math.random();}
    console.log("Original Schraudolph's algorithm:");
    for (var loop = 0; loop < RUNS; loop++) {
        start[loop] = performance.now();
        fastexp_v128(START, NUMNUMS * v128_SIZE);
        end[loop] = performance.now()
        for (var i = START; i < NUMNUMS; i++) { vals[i] = Math.random(); }
    }
    for (var i = 0; i < RUNS; i++) { diff[i] = (end[i] - start[i]) }
    console.log(`Time: ${(diff.reduce((acc, cur) => { return acc + cur }, 0)) / RUNS} ms / run.`);    


    // wasm-fun, lower relative error, external JS loop -- obviously going to be slower, but how much?
    // 20x slower than v128 -- scratchpad internal loop version is ~10x slower than v128
    for (var i = START; i < NUMNUMS; i++) {vals[i] = Math.random();}
    console.log("wasm-fun algorithm:");
    for (var loop = 0; loop < RUNS; loop++) {
        start[loop] = performance.now();
        for (var i = START; i < NUMNUMS; i++) {vals[i] = fastexp(vals[i]);}
        end[loop] = performance.now()
        for (var i = START; i < NUMNUMS; i++) { vals[i] = Math.random(); }
    }
    for (var i = 0; i < RUNS; i++) { diff[i] = (end[i] - start[i]) }
    console.log(`Time: ${(diff.reduce((acc, cur) => { return acc + cur }, 0)) / RUNS} ms / run.`);


})();
