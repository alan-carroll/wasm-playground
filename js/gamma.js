const fs = require("fs");
// const bytes = fs.readFileSync(__dirname + "/../wasm/fast_exp.wasm");

let memory = new WebAssembly.Memory({ initial: 1 });
let impObj = { env: { mem: memory } };

async function load_fast_exp() {
    let obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/fast_exp.wasm")), impObj);
    return obj.instance;
}

async function load_pow() {
    let obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/pow_funcs.wasm")));
    return obj.instance;
}

async function load_sincos() {
    let obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/sincos.wasm")));
    return obj.instance;
}

(async () => {
    let fastexp = await load_fast_exp();
    let pow_funcs = await load_pow();
    let sincos = await load_sincos();
    let obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/gamma.wasm")), 
            {fast_exp: {fastexp: fastexp.exports.fastexp},
             pow_funcs: {pow: pow_funcs.exports.pow},
             sincos: {sin: sincos.exports.sin,
                      cos: sincos.exports.cos}});
    const { gamma } = obj.instance.exports;

    for (var i = 0; i < 10; i++) {
        console.log(`x: ${i}\tgamma: ${gamma(i)}`)
    }

})();
