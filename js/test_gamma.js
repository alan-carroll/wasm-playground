const fs = require("fs");
const cephes = require("cephes");
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

async function load_gamma_v2() {
    let f = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/fast_exp_v4.wasm")), impObj);
    let p = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/pow_funcs_v2.wasm")));
    let s = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/sincos_v2.wasm")), {pow_funcs: {ldexp: p.instance.exports.ldexp}});
    let g = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/gamma_v2.wasm")), {fast_exp: {fastexp: f.instance.exports.fastexp},
                                                                                pow_funcs: {pow: p.instance.exports.pow},
                                                                                sincos: {sin: s.instance.exports.sin,
                                                                                         cos: s.instance.exports.cos}});
    return g.instance
}

(async () => {
    let fastexp = await load_fast_exp();
    let pow_funcs = await load_pow();
    let sincos = await load_sincos();
    let obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/gamma.wasm")),
        {
            fast_exp: { fastexp: fastexp.exports.fastexp },
            pow_funcs: { pow: pow_funcs.exports.pow },
            sincos: {
                sin: sincos.exports.sin,
                cos: sincos.exports.cos
            }
        });
    const { gamma } = obj.instance.exports;

    let sm_obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/single_module_gamma.wasm")),
        {}
    );
    const { gamma: sm_gamma } = sm_obj.instance.exports;

    let wosm_obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/wo_single_module_gamma.wasm")),
        {}
    );
    const { gamma: wosm_gamma } = wosm_obj.instance.exports;

    let sm2_obj = await WebAssembly.instantiate(
        new Uint8Array(fs.readFileSync(__dirname + "/../wasm/single_module_gamma_v2.wasm")),
        {}
    );
    const { gamma: sm2_gamma } = sm2_obj.instance.exports;

    let gamma_v2 = await load_gamma_v2();
    const {gamma: split2_gamma} = gamma_v2.exports;

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
    // also curious what the performance difference is for:
    // - same module vs. imported func calls
    // - full f32 version throughout, with/without 'fast' versions

    console.log("Running single-module wasm cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // gamma(Math.random()*100);
        sm_gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)
    // naively not any faster than split modules + imports
    // 1e9 trials with Math.random() and it was only 1 s faster than split
    // Probably within margin of error anyway

    console.log("Running wasm-opt single-module wasm cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // gamma(Math.random()*100);
        wosm_gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)
    // not any faster right now, handwriting WAT might be doing the heavy work
    // for me right now lol

    console.log("Running single-module v2 wasm cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // gamma(Math.random()*100);
        sm2_gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)
    // still the same as smv1 and split

    console.log("Running split module v2 wasm cephes:");
    start = performance.now();
    for (var i = 1; i < trials; i++) {
        //console.log(`x: ${i}\tgamma: ${cephes.gamma(i)}`)
        // gamma(Math.random()*100);
        split2_gamma(Math.random());
    }
    end = performance.now();
    console.log(`Total time: ${end - start}\n`)
    // yea none of it matters. All the code changes, global/local,
    // single module or split, it's all within a margin of error

})();
