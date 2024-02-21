const fs = require("fs");
const cephes = require("cephes");

let memory = new WebAssembly.Memory({ initial: 1 });
let impObj = { env: { mem: memory } };

async function load_gamma () {
    let f = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/fast_exp.wasm")), impObj);
    let p = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/pow_funcs.wasm")));
    let s = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/sincos.wasm")), {pow_funcs: {ldexp: p.instance.exports.ldexp}});
    let g = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/gamma.wasm")), {fast_exp: {fastexp: f.instance.exports.fastexp},
                                                                                pow_funcs: {pow: p.instance.exports.pow},
                                                                                sincos: {sin: s.instance.exports.sin,
                                                                                         cos: s.instance.exports.cos}});
    return g.instance
}

(async () => {
    let gamma_obj = await load_gamma();
    const {gamma} = gamma_obj.exports;

    trials = 1e9;

    console.log("Running node cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // cephes.gamma(Math.random() * 100);
        cephes.gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)

    console.log("Running wasm cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // gamma(Math.random()*100);
        gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)
    // naively typically ~30-50% faster :D
    // curious how much is due to fastexp.. Should try with normal f64 version

})();
