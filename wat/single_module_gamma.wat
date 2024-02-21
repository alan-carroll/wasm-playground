(module

  ;; https://github.com/jeremybarnes/cephes/blob/master/cprob/polevl.c

  ;; $frexp
  ;; https://www.netlib.org/fdlibm/s_frexp.c

  ;; $ldexp
  ;; https://android.googlesource.com/platform/bionic/+/a27d2baa/libc/bionic/ldexp.c
  ;; https://www.netlib.org/fdlibm/s_ldexp.c
  ;; https://www.netlib.org/fdlibm/s_scalbn.c

  ;; $powi
  ;; https://github.com/jeremybarnes/cephes/blob/master/cmath/powi.c
  ;; ifdef UNK, DENORMAL

  ;; $pow
  ;; https://github.com/jeremybarnes/cephes/blob/master/cmath/pow.c
  ;; ifdef UNK, DENORMAL

  ;; https://www.netlib.org/cephes/
  ;; cmath sin.c

  ;; https://github.com/scipy/scipy/blob/main/scipy/special/cephes/gamma.c
  ;; Modified from f64 to f32 since `fastexp` overflow limit < MAXGAM

  (memory 1)

  ;; global arrays
  ;;;; gamma
  (global $gamma_P_addr i32 (i32.const 0)) ;; _start_ (0)
  (global $gamma_P_count i32 (i32.const 7))
  (global $gamma_Q_addr i32 (i32.const 56)) ;; $gamma_P_addr (0) + $gamma_P_count (7) * 8 = 56
  (global $gamma_Q_count i32 (i32.const 8))
  (global $gamma_STIR_addr i32 (i32.const 120)) ;; $gamma_Q_addr (56) + $gamma_Q_count (8) * 8 = 120
  (global $gamma_STIR_count i32 (i32.const 5))
  ;;;; end gamma
  ;;;; sincos
  (global $sincof_addr i32 (i32.const 160)) ;; $gamma_STIR_addr (120) + $gamma_STIR_count (5) * 8 = 160
  (global $sincof_count i32 (i32.const 6))
  (global $coscof_addr i32 (i32.const 208)) ;; $sincof_addr (160) + $sincof_count (6) * 8 = 208
  (global $coscof_count i32 (i32.const 6))
  ;;;; end sincos
  ;;;; pow
  (global $pow_P_addr i32 (i32.const 256)) ;; $coscof_addr (208) + $coscof_count (6) * 8 = 256
  (global $pow_P_count i32 (i32.const 4))
  (global $pow_Q_addr i32 (i32.const 288)) ;; $pow_P_addr (256) + $pow_P_count (4) * 8 = 288
  (global $pow_Q_count i32 (i32.const 4))
  (global $pow_A_addr i32 (i32.const 320)) ;; $pow_Q_addr (288) + $pow_Q_count (4) * 8 = 320
  (global $pow_A_count i32 (i32.const 17))
  (global $pow_B_addr i32 (i32.const 456)) ;; $pow_A_addr (320) + $pow_A_count (17) * 8 = 456
  (global $pow_B_count i32 (i32.const 9))
  (global $pow_R_addr i32 (i32.const 528)) ;; $pow_B_addr (456) + $pow_B_count (9) * 8 = 528
  (global $pow_R_count i32 (i32.const 7))
  ;;;; end pow
  ;; end global arrays
  
  ;; global constants
  ;;;; gamma
  ;; Modified to match `fastexp` overflow limit (global $MAXGAM f64 (f64.const 171.624376956302725))
  (global $MAXGAM f64 (f64.const 88.72283))
  (global $LOGPI f64 (f64.const 1.14472988584940017414))
  (global $MAXSTIR f64 (f64.const 143.01608))
  (global $SQTPI f64 (f64.const 2.50662827463100050242E0))
  (global $MAXLOG f64 (f64.const 7.09782712893383996732E2))
  (global $M_PI f64 (f64.const 3.14159265358979323846))
  ;;;; end gamma
  ;;;; sincos globals
  (global $DP1 f64 (f64.const 7.85398125648498535156E-1))
  (global $DP2 f64 (f64.const 3.77489470793079817668E-8))
  (global $DP3 f64 (f64.const 2.69515142907905952645E-15))
  (global $lossth f64 (f64.const 1.073741824e9))
  (global $PIO4 f64 (f64.const 7.85398163397448309616E-1))
  ;;;; end sincos
  ;;;; frexp / ldexp globals
  (global $two54 f64 (f64.const 1.80143985094819840000e+16))
  (global $twom54 f64 (f64.const 5.55111512312578270212e-17))
  (global $MAXNUM f64 (f64.const 1.79769313486231570815E308))
  (global $MINLOG f64 (f64.const -7.451332191019412076235E2))
  (global $LOG2E f64 (f64.const 1.4426950408889634073599))
  ;;;; end ldexp
  ;;;; pow globals
  (global $SQRTH f64 (f64.const 0.70710678118654752440))
  (global $MEXP f64 (f64.const 16383.0))
  (global $MNEXP f64 (f64.const -17183.0)) ;; denormal
  (global $LOG2EA f64 (f64.const 0.44269504088896340736)) ;; log2(e) - 1
  ;;;; end pow
  ;; end global constants

  (start $init)

  (func $_store (param $addr i32) (param $idx i32) (param $val f64)
    (f64.store align=8 
      (i32.add (local.get $addr) (i32.mul (local.get $idx) (i32.const 8)))
      (local.get $val))
  )

  (func $_load (param $addr i32) (param $idx i32) (result f64)
    (f64.load align=8 
      (i32.add (local.get $addr) (i32.mul (local.get $idx) (i32.const 8))))
  )

  (func $init
    ;; gamma
    ;; gamma P array
    (call $_store (global.get $gamma_P_addr) (i32.const 0) (f64.const 1.60119522476751861407E-4))
    (call $_store (global.get $gamma_P_addr) (i32.const 1) (f64.const 1.19135147006586384913E-3))
    (call $_store (global.get $gamma_P_addr) (i32.const 2) (f64.const 1.04213797561761569935E-2))
    (call $_store (global.get $gamma_P_addr) (i32.const 3) (f64.const 4.76367800457137231464E-2))
    (call $_store (global.get $gamma_P_addr) (i32.const 4) (f64.const 2.07448227648435975150E-1))
    (call $_store (global.get $gamma_P_addr) (i32.const 5) (f64.const 4.94214826801497100753E-1))
    (call $_store (global.get $gamma_P_addr) (i32.const 6) (f64.const 9.99999999999999996796E-1))
    ;; gamma Q array
    (call $_store (global.get $gamma_Q_addr) (i32.const 0) (f64.const -2.31581873324120129819E-5))
    (call $_store (global.get $gamma_Q_addr) (i32.const 1) (f64.const 5.39605580493303397842E-4))
    (call $_store (global.get $gamma_Q_addr) (i32.const 2) (f64.const -4.45641913851797240494E-3))
    (call $_store (global.get $gamma_Q_addr) (i32.const 3) (f64.const 1.18139785222060435552E-2))
    (call $_store (global.get $gamma_Q_addr) (i32.const 4) (f64.const 3.58236398605498653373E-2))
    (call $_store (global.get $gamma_Q_addr) (i32.const 5) (f64.const -2.34591795718243348568E-1))
    (call $_store (global.get $gamma_Q_addr) (i32.const 6) (f64.const 7.14304917030273074085E-2))
    (call $_store (global.get $gamma_Q_addr) (i32.const 7) (f64.const 1.00000000000000000320E0))
    ;; gamma STIR array
    (call $_store (global.get $gamma_STIR_addr) (i32.const 0) (f64.const 7.87311395793093628397E-4))
    (call $_store (global.get $gamma_STIR_addr) (i32.const 1) (f64.const -2.29549961613378126380E-4))
    (call $_store (global.get $gamma_STIR_addr) (i32.const 2) (f64.const -2.68132617805781232825E-3))
    (call $_store (global.get $gamma_STIR_addr) (i32.const 3) (f64.const 3.47222221605458667310E-3))
    (call $_store (global.get $gamma_STIR_addr) (i32.const 4) (f64.const 8.33333333333482257126E-2))
    ;; end gamma
    ;; sincos
    ;; sincof array
    (call $_store (global.get $sincof_addr) (i32.const 0) (f64.const  1.58962301576546568060E-10))
    (call $_store (global.get $sincof_addr) (i32.const 1) (f64.const -2.50507477628578072866E-8))
    (call $_store (global.get $sincof_addr) (i32.const 2) (f64.const  2.75573136213857245213E-6))
    (call $_store (global.get $sincof_addr) (i32.const 3) (f64.const -1.98412698295895385996E-4))
    (call $_store (global.get $sincof_addr) (i32.const 4) (f64.const  8.33333333332211858878E-3))
    (call $_store (global.get $sincof_addr) (i32.const 5) (f64.const -1.66666666666666307295E-1))
    ;; coscof array
    (call $_store (global.get $coscof_addr) (i32.const 0) (f64.const -1.13585365213876817300E-11))
    (call $_store (global.get $coscof_addr) (i32.const 1) (f64.const  2.08757008419747316778E-9))
    (call $_store (global.get $coscof_addr) (i32.const 2) (f64.const -2.75573141792967388112E-7))
    (call $_store (global.get $coscof_addr) (i32.const 3) (f64.const  2.48015872888517045348E-5))
    (call $_store (global.get $coscof_addr) (i32.const 4) (f64.const -1.38888888888730564116E-3))
    (call $_store (global.get $coscof_addr) (i32.const 5) (f64.const  4.16666666666665929218E-2))
    ;; end sincos
    ;; pow
    ;; pow P array
    (call $_store (global.get $pow_P_addr) (i32.const 0) (f64.const 4.97778295871696322025E-1))
    (call $_store (global.get $pow_P_addr) (i32.const 1) (f64.const 3.73336776063286838734E0))
    (call $_store (global.get $pow_P_addr) (i32.const 2) (f64.const 7.69994162726912503298E0))
    (call $_store (global.get $pow_P_addr) (i32.const 3) (f64.const 4.66651806774358464979E0))
    ;; pow Q array
    (call $_store (global.get $pow_Q_addr) (i32.const 0) (f64.const 9.33340916416696166113E0))
    (call $_store (global.get $pow_Q_addr) (i32.const 1) (f64.const 2.79999886606328401649E1))
    (call $_store (global.get $pow_Q_addr) (i32.const 2) (f64.const 3.35994905342304405431E1))
    (call $_store (global.get $pow_Q_addr) (i32.const 3) (f64.const 1.39995542032307539578E1))
    ;; pow A array
    (call $_store (global.get $pow_A_addr) (i32.const 0) (f64.const 1.00000000000000000000E0))
    (call $_store (global.get $pow_A_addr) (i32.const 1) (f64.const 9.57603280698573700036E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 2) (f64.const 9.17004043204671215328E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 3) (f64.const 8.78126080186649726755E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 4) (f64.const 8.40896415253714502036E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 5) (f64.const 8.05245165974627141736E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 6) (f64.const 7.71105412703970372057E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 7) (f64.const 7.38413072969749673113E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 8) (f64.const 7.07106781186547572737E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 9) (f64.const 6.77127773468446325644E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 10) (f64.const 6.48419777325504820276E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 11) (f64.const 6.20928906036742001007E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 12) (f64.const 5.94603557501360513449E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 13) (f64.const 5.69394317378345782288E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 14) (f64.const 5.45253866332628844837E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 15) (f64.const 5.22136891213706877402E-1))
    (call $_store (global.get $pow_A_addr) (i32.const 16) (f64.const 5.00000000000000000000E-1))
    ;; pow B array
    (call $_store (global.get $pow_B_addr) (i32.const 0) (f64.const 0.00000000000000000000E0))
    (call $_store (global.get $pow_B_addr) (i32.const 1) (f64.const 1.64155361212281360176E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 2) (f64.const 4.09950501029074826006E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 3) (f64.const 3.97491740484881042808E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 4) (f64.const -4.83364665672645672553E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 5) (f64.const 1.26912513974441574796E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 6) (f64.const 1.99100761573282305549E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 7) (f64.const -1.52339103990623557348E-17))
    (call $_store (global.get $pow_B_addr) (i32.const 8) (f64.const 0.00000000000000000000E0))
    ;; pow R array
    (call $_store (global.get $pow_R_addr) (i32.const 0) (f64.const 1.49664108433729301083E-5))
    (call $_store (global.get $pow_R_addr) (i32.const 1) (f64.const 1.54010762792771901396E-4))
    (call $_store (global.get $pow_R_addr) (i32.const 2) (f64.const 1.33335476964097721140E-3))
    (call $_store (global.get $pow_R_addr) (i32.const 3) (f64.const 9.61812908476554225149E-3))
    (call $_store (global.get $pow_R_addr) (i32.const 4) (f64.const 5.55041086645832347466E-2))
    (call $_store (global.get $pow_R_addr) (i32.const 5) (f64.const 2.40226506959099779976E-1))
    (call $_store (global.get $pow_R_addr) (i32.const 6) (f64.const 6.93147180559945308821E-1))
    ;; end pow
  )

  (func $fastexp_v128 (export "fastexp_v128") (param $idx i32) (param $SIZE i32)
    ;; https://stackoverflow.com/a/47025627 Schraudolph's algorithm
    ;; Max relative error 3.55959567e-2 on [-87.33654, 88.72283]
    (local $UNDER v128)
    (local $OVER v128)
    (local $INFS v128)
    (local $under_mask v128)
    (local $over_mask v128)
    (local $a v128)
    (local $b v128)
    (local $x v128)

    (local.set $UNDER (f32x4.splat (f32.const -87.33654)))
    (local.set $OVER (f32x4.splat (f32.const 88.72283)))
    (local.set $INFS (f32x4.splat (f32.const inf)))
    (local.set $a (f32x4.splat (f32.const 12102203)))
    (local.set $b (i32x4.splat (i32.sub 
      (i32.mul (i32.const 127) (i32.shl (i32.const 1) (i32.const 23))) 
      (i32.const 298765))))

    (loop $vec
      (local.get $idx) ;; leave idx on stack for saving back to memory
      (local.tee $x (v128.load align=4 (local.get $idx)))
      
      ;; Set masks to protect against under/overflow
      (local.set $under_mask (f32x4.ge (local.get $UNDER)))
      (local.set $over_mask (f32x4.le (local.get $x) (local.get $OVER)))

      ;; Calc exp and adjust output with under/over masks (->0, ->+inf, respectively)
      (local.tee $x (v128.bitselect
        (v128.and 
          (i32x4.add (local.get $b) (i32x4.trunc_sat_f32x4_s (f32x4.mul (local.get $a) (local.get $x)))) 
          (local.get $under_mask))
        (local.get $INFS)
        (local.get $over_mask)))
        
      (v128.store align=4) ;; idx, x on stack
      
      ;; Advance index or exit loop
      (i32.lt_s (local.tee $idx (i32.add (local.get $idx) (i32.const 16))) (local.get $SIZE))
      br_if $vec)
  )

  (func $fastexp (export "fastexp") (param $x f32) (result f32)
    ;; https://github.com/alan-carroll/wasm-fun/blob/875fb215d089fa4a7596a2f1f83b281137071917/wat/random.wat#L133
    ;; Added under/overflow protection
    (local $m i32)
    (local $i i32)

    ;; Under/overflow
    (if (f32.le (local.get $x) (f32.const -87.33654)) (then (f32.const 0) return))
    (if (f32.ge (local.get $x) (f32.const 88.72283)) (then (f32.const inf) return))

    (local.set $m (i32.and 
      (i32.shr_u 
        (local.tee $i (i32.add
          (i32.trunc_f32_s (f32.mul (local.get $x) (f32.const 12102203.0)))
          (i32.const 1065353216)))
        (i32.const 7))
      (i32.const 0xffff)))
    (local.tee $i (i32.add (local.get $i)
      (i32.sub (i32.shr_s  (i32.mul
      (i32.sub (i32.shr_s  (i32.mul
      (i32.add (i32.shr_s  (i32.mul 
        (i32.const 1277 )  (local.get $m)) (i32.const 14))
        (i32.const 14825)) (local.get $m)) (i32.const 14))
        (i32.const 79749)) (local.get $m)) (i32.const 11))
        (i32.const 626  ))))
    
    f32.reinterpret_i32
  )

  (func $reduc (param $x f64) (result f64)
    (call $ldexp (local.get $x) (i32.const 4))
    f64.floor
    i32.const -4
    call $ldexp    
  )
  
  (func $frexp (export "frexp") (param $x f64) (result f64 i32)
    (local $hx i32)
    (local $lx i32)
    (local $ix i32)
    (local $exp i32)
    (local $_x i64)

    (local $two54 f64)
    (local.set $two54 (f64.const 1.80143985094819840000e+16))

    (local.tee $_x (i64.reinterpret_f64 (local.get $x)))
    (local.set $hx (i32.wrap_i64 (i64.shr_s (i64.const 32))))
    (local.set $lx (i32.wrap_i64 (local.get $_x)))

    ;; Check for 0/inf/nan
    (local.tee $ix (i32.and (i32.const 0x7fffffff) (local.get $hx)))
    (i32.ge_s (i32.const 0x7ff00000))
    (i32.or (i32.eqz (i32.or (local.get $ix) (local.get $lx))))
    if (local.get $x) (local.get $exp) return end
    
    ;; Check if subnormal
    (if (i32.lt_s (local.get $ix) (i32.const 0x00100000)) (then 
      (i64.reinterpret_f64 (f64.mul (local.get $x) (local.get $two54)))
      (local.tee $hx (i32.wrap_i64 (i64.shr_s (i64.const 32))))
      (local.set $ix (i32.and (i32.const 0x7fffffff)))
      (local.set $exp (i32.const -54))))

    (local.set $exp (i32.add 
      (local.get $exp)
      (i32.sub 
        (i32.shr_u (local.get $ix) (i32.const 20))
        (i32.const 1022))))
    (local.set $hx (i32.or
      (i32.and (local.get $hx) (i32.const 0x800fffff))
      (i32.const 0x3fe00000)))

    (i64.or ;; combine high/low bits (SET_HIGH_WORD)
      (i64.and (i64.reinterpret_f64 (local.get $x)) (i64.const 0xFFFFFFFF)) ;; keep low 32 bits
      (i64.shl (i64.extend_i32_u (local.get $hx)) ;; i32 to i64 and shift 32 bits higher
        (i64.const 32)))
    f64.reinterpret_i64 ;; return x
    (local.get $exp) ;; return exp
  )
  
  (func $ldexp (export "ldexp") (param $x f64) (param $n i32) (result f64)
    (local $k i32)
    (local $hx i32)
    (local $lx i32)
    (local $_x i64)

    (local $two54 f64) 
    (local $twom54 f64)
    (local.set $two54 (f64.const 1.80143985094819840000e+16))
    (local.set $twom54 (f64.const 5.55111512312578270212e-17))

    (local.tee $_x (i64.reinterpret_f64 (local.get $x)))
    (local.set $hx (i32.wrap_i64 (i64.shr_s (i64.const 32))))
    (local.set $lx (i32.wrap_i64 (local.get $_x)))

    ;; extract exponent
    (local.tee $k (i32.shr_s (i32.and (local.get $hx) (i32.const 0x7ff00000)) (i32.const 20)))
    (if (i32.eqz) ;; 0 or subnormal
      (then (if (i32.or (local.get $lx) (i32.and (local.get $hx) (i32.const 0x7fffffff))) ;; != 0
        (then (if (i32.lt_s (local.get $n) (i32.const -50000))
          (then (if (f64.gt (f64.const 0) (local.get $x))
            (then (f64.const 0) return)
            (else (f64.const -0) return)))
          (else 
            (i64.reinterpret_f64 (local.tee $x (f64.mul (local.get $x) (local.get $two54))))
            (local.tee $hx (i32.wrap_i64 (i64.shr_s (i64.const 32))))
            (local.set $k (i32.sub 
              (i32.shr_s (i32.and (i32.const 0x7ff00000)) (i32.const 20))
              (i32.const 54))))))
        (else (local.get $x) return)))) ;; == 0
    
    (if (i32.eq (local.get $k) (i32.const 0x7ff)) ;; Check for inf/nan
      (then (f64.add (local.get $x) (local.get $x)) return))

    (local.tee $k (i32.add (local.get $k) (local.get $n)))
    (if (i32.gt_s (i32.const 0x7fe)) ;; overflow
      (then (if (f64.gt (local.get $x) (f64.const 0))
        (then (f64.const inf) return)
        (else (f64.const -inf) return))))
    
    (if (i32.gt_s (local.get $k) (i32.const 0)) (then ;; normal result
      (i64.or ;; combine high/low bits (SET_HIGH_WORD)
        (i64.and (i64.reinterpret_f64 (local.get $x)) (i64.const 0xFFFFFFFF)) ;; keep low 32 bits
        (i64.shl (i64.extend_i32_u ;; i32 to i64 and shift 32 bits higher
          (i32.or
            (i32.and (local.get $hx) (i32.const 0x800fffff))
            (i32.shl (local.get $k) (i32.const 20))))
          (i64.const 32)))
      f64.reinterpret_i64 return))
      
    (if (i32.le_s (local.get $k) (i32.const -54))
      (then (if (i32.gt_s (local.get $n) (i32.const 50000)) ;; overflow
        (then (if (f64.gt (local.get $x) (f64.const 0))
          (then (f64.const inf) return)
          (else (f64.const -inf) return)))
        (else ;; underflow
          (if (f64.gt (f64.const 0) (local.get $x))
            (then (f64.const 0) return)
            (else (f64.const -0) return))))))

    (local.set $k (i32.add (local.get $k) (i32.const 54))) ;; subnormal result
    (i64.or ;; combine high/low bits (SET_HIGH_WORD)
        (i64.and (i64.reinterpret_f64 (local.get $x)) (i64.const 0xFFFFFFFF)) ;; keep low 32 bits
        (i64.shl (i64.extend_i32_u ;; i32 to i64 and shift 32 bits higher
          (i32.or
            (i32.and (local.get $hx) (i32.const 0x800fffff))
            (i32.shl (local.get $k) (i32.const 20))))
          (i64.const 32)))
    f64.reinterpret_i64

    (f64.mul (local.get $twom54))
  )
  
  (func $powi (export "powi") (param $x f64) (param $nn i32) (result f64)
    (local $n i32)
    (local $e i32)
    (local $sign i32)
    (local $asign i32)
    (local $lx i32)
    (local $w f64)
    (local $y f64)
    (local $s f64)

    (local $MAXLOG f64)
    (local $MINLOG f64)
    (local $LOG2E f64)
    (local.set $MAXLOG (f64.const 7.09782712893383996732E2))
    (local.set $MINLOG (f64.const -7.451332191019412076235E2))
    (local.set $LOG2E (f64.const 1.4426950408889634073599))

    (block $done

      ;; #L64-81 skipping tests as already done by `pow`

      ;; #L83 nn == -1
      (if (i32.eq (local.get $nn) (i32.const -1)) (then (f64.div (f64.const 1) (local.get $x)) (br $done)))
      ;; #L95 nn < 0
      (if (i32.lt_s (local.get $nn) (i32.const 0)) 
        (then (local.set $sign (i32.const -1)) (local.set $n (i32.sub (i32.const 0) (local.get $nn))))
        (else (local.set $sign (i32.const 1) (local.set $n (local.get $nn)))))

      ;; Combine #L86 x < 0.0 and #L107 (n & 1) -> odd power, determines $asign
      (if (f64.lt (local.get $x) (f64.const 0)) (then 
        (local.set $x (f64.neg (local.get $x)))
        (if (i32.and (local.get $n) (i32.const 1)) (then (local.set $asign (i32.const -1))))))
      
      ;; #L112 Calc approx log of answer
      (call $frexp (local.get $x))
      (local.set $lx)
      (local.set $s)
      (block $or_erange (result i32)
        (local.tee $e (i32.mul (local.get $n) (i32.sub (local.get $lx) (i32.const 1))))
        i32.eqz if (i32.const 1) (br $or_erange) end
        (i32.gt_s (local.get $e) (i32.const 64)) if (i32.const 1) (br $or_erange) end
        (i32.const 1) (i32.const 0) (i32.lt_s (local.get $e) (i32.const -64)) select)
      if (result f64) ;; pass s
        (f64.div (f64.sub (local.get $s) (f64.const 7.0710678118654752e-1)) ;; #L117, s on the stack
          (f64.add (local.get $s) (f64.const 7.0710678118654752e-1)))
        (f64.const 2.9142135623730950) f64.mul
        f64.const 0.5 f64.sub
        (f64.convert_i32_s (local.get $lx)) f64.add
        (f64.convert_i32_s (local.get $nn)) f64.mul
        (local.get $LOG2E) f64.mul
        (local.tee $s)
      else (local.tee $s (f64.mul (f64.convert_i32_s (local.get $e)) (local.get $LOG2E))) end ;; #L122, s on the stack
      (local.get $MAXLOG) f64.gt if (local.set $y (f64.const inf)) (br $done) end ;; #L125

      ;; #L132 handle denormal
      (if (f64.lt (local.get $s) (local.get $MINLOG)) (then (local.set $y (f64.const 0)) (br $done)))
      ;; #L143 more denormal
      (f64.lt (local.get $s) (f64.add (f64.neg (local.get $MAXLOG)) (f64.const 2))) ;; (s < (-MAXLOG+2.0))
      (i32.lt_s (local.get $sign) (i32.const 0)) ;; (sign < 0)
      i32.and
      if 
        (local.set $x (f64.div (f64.const 1) (local.get $x)))
        (local.set $sign (i32.sub (i32.const 0) (local.get $sign)))
      end

      ;; #L156 - 'First bit of power'
      (i32.and (local.get $n) (i32.const 1))
      if (local.set $y (local.get $x)) else (local.set $y (f64.const 1)) end
      (local.set $w (local.get $x))
      (local.tee $n (i32.shr_s (local.get $n) (i32.const 1)))
      if
        (loop $while
          (local.set $w (f64.mul (local.get $w) (local.get $w)))
          (if (i32.and (local.get $n) (i32.const 1)) (then
            (local.set $y (f64.mul (local.get $y) (local.get $w)))))
          (local.tee $n (i32.shr_s (local.get $n) (i32.const 1)))
          br_if $while)
      end

      (if (i32.lt_s (local.get $sign) (i32.const 0)) (then
        (local.set $y (f64.div (f64.const 1) (local.get $y)))))
    ) ;; end $done

    ;; #L175 - done:
    (if (local.get $asign) ;; odd power of negative number
      (then (if (f64.eq (local.get $y) (f64.const 0))
        (then (f64.const -0) return)
        (else (f64.neg (local.get $y)) return))))
      
    (local.get $y)
  )

  (func $pow (export "pow") (param $x f64) (param $y f64) (result f64)
    (local $w f64)
    (local $z f64)
    (local $W f64)
    (local $Wa f64)
    (local $Wb f64)
    (local $ya f64)
    (local $yb f64)
    (local $u f64)
    (local $aw f64)
    (local $ay f64)
    (local $wy f64)
    (local $e i32)
    (local $i i32)
    (local $nflg i32)
    (local $iyflg i32)
    (local $yoddint i32)
    (local $_polans f64)
    (local $_ptr i32)
    (local $_N i32)

    (local $SQRTH f64)
    (local $MEXP f64)
    (local $MNEXP f64)
    (local $LOG2EA f64)
    (local $MAXNUM f64)
    (local $P_addr i32)
    (local $Q_addr i32)
    (local $A_addr i32)
    (local $B_addr i32)
    (local $R_addr i32)
    (local.set $SQRTH (f64.const 0.70710678118654752440))
    (local.set $MEXP (f64.const 16383.0))
    (local.set $MNEXP (f64.const -17183.0)) ;; denormal
    (local.set $LOG2EA (f64.const 0.44269504088896340736)) ;; log2(e) - 1
    (local.set $MAXNUM (f64.const 1.79769313486231570815E308))
    (local.set $P_addr (i32.const 256))
    (local.set $Q_addr (i32.const 288))
    (local.set $A_addr (i32.const 320))
    (local.set $B_addr (i32.const 456))
    (local.set $R_addr (i32.const 528))

    (if (f64.eq (local.get $y) (f64.const 0)) (then (f64.const 1) return)) ;; #L374 y == 0.0
    (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) return)) ;; isnan(x)
    (if (i32.eqz (f64.eq (local.get $y) (local.get $y))) (then (local.get $y) return)) ;; isnan(y)
    (if (f64.eq (local.get $y) (f64.const 1)) (then (local.get $x) return)) ;; y == 1.0

    ;; isfinite(y) - checks +/- inf and nan
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $y)) (i64.const 32)))
    (i32.ne (i32.and (i32.const 0x7ff00000)) (i32.const 0x7ff00000))
    (if (i32.eqz) ;; y not finite #L387
      (then (if (f64.eq (local.get $x) (f64.const 1))
        (then (f64.const nan) return) ;; x == 1.0
        (else (if (f64.eq (local.get $x) (f64.const -1)) (then (f64.const nan) return)))))) ;; or x == -1.0

    (if (f64.eq (local.get $x) (f64.const 1)) (then (f64.const 1) return)) ;; #L398 x == 1.0
    (if (f64.ge (local.get $y) (local.get $MAXNUM)) (then ;; y >= MAXNUM #L401
      (if (f64.gt (local.get $x) (f64.const 1)) (then (f64.const inf) return)) ;; x > 1.0
      (if (f64.gt (local.get $x) (f64.const 0)) ;; 0.0 > x && x < 1.0
        (then (if (f64.lt (local.get $x) (f64.const 1)) (then (f64.const 0) return))))
      (if (f64.lt (local.get $x) (f64.const -1)) (then (f64.const inf) return)) ;; x < -1.0
      (if (f64.gt (local.get $x (f64.const -1))) ;; x > -1.0 && x < 0.0
        (then (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const 0) return))))))
    (if (f64.le (local.get $y) (f64.neg (local.get $MAXNUM))) (then ;; y <= -MAXNUM #L423
      (if (f64.gt (local.get $x) (f64.const 1)) (then (f64.const 0) return)) ;;  x > 1.0
      (if (f64.gt (local.get $x) (f64.const 0)) ;; x > 0.0 && x < 1.0
        (then (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const inf) return))))
      (if (f64.lt (local.get $x) (f64.const -1)) (then (f64.const 0) return)) ;; x < -1.0
      (if (f64.gt (local.get $x) (f64.const -1)) ;; x > -1.0 && x < 0.0
        (then (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const inf) return)))))) 
    (if (f64.ge (local.get $x) (local.get $MAXNUM)) ;; x >= MAXNUM #L444
      (then (if (f64.gt (local.get $y) (f64.const 0)) ;; y > 0.0
        (then (f64.const inf) return)
        (else (f64.const 0) return))))

    ;; #L456 - is y an int
    (local.tee $w (f64.floor (local.get $y)))
    (local.tee $iyflg (f64.eq (local.get $y)))
    if ;; #L461 - is y odd int
      (local.tee $ya (f64.floor (f64.mul (f64.const 0.5) (f64.abs (local.get $y)))))
      (local.set $yoddint (f64.ne (local.tee $yb (f64.mul (f64.const 0.5) (f64.abs (local.get $w))))))
    end

    (if (f64.le (local.get $x) (f64.neg (local.get $MAXNUM))) (then ;; x <= -MAXNUM #L472
      (if (f64.gt (local.get $y) (f64.const 0)) ;; y > 0.0
        (then (if (local.get $yoddint) ;; yoddint
          (then (f64.const -inf) return) 
          (else (f64.const inf) return)))) 
      (if (f64.lt (local.get $y) (f64.const 0)) ;; y < 0.0
        (then (if (local.get $yoddint) ;; yoddint
          (then (f64.const -0) return) 
          (else (f64.const 0) return)))))) 
    
    ;; #L496 - is x<0 raised to int power
    (if (f64.le (local.get $x) (f64.const 0)) ;; x <= 0.0
      (then (if (f64.eq (local.get $x) (f64.const 0)) ;; x == 0.0
        (then 
          (if (f64.lt (local.get $y) (f64.const 0)) ;; y < 0.0
            (then
              (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32)))
              (i32.and (i32.lt_s (i32.const 0)) (local.get $yoddint)) ;; signbit(x) && yoddint
              if (f64.const -inf) return else (f64.const inf) return end))
          (if (f64.gt (local.get $y) (f64.const 0)) ;; y > 0.0
            (then 
              (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32)))
              (i32.and (i32.lt_s (i32.const 0)) (local.get $yoddint)) ;; signbit(x) && yoddint
              if (f64.const -0) return else (f64.const 0) return end))
          (f64.const 1) return) ;; implicit y==0 #L521
        (else ;; implicit x < 0.0 #L523
          (if (local.get $iyflg) (then (f64.const nan) return)) ;; noninteger power of negative number
          (local.set $nflg (i32.const 1))))))
    
    ;; #L540 - int power of an int
    (if (local.get $iyflg) (then (if (f64.eq (local.tee $w (f64.floor (local.get $x))) (local.get $x)) ;; (w == x)
      (then (if (f64.lt (f64.abs (local.get $y)) (f64.const 32768.0)) ;; && (fabs(y) < 32768.0)
        (then (call $powi (local.get $x) (i32.trunc_f64_s (local.get $y))) return))))))

    (local.get $nflg) if (local.set $x (f64.abs (local.get $x))) end ;; #L551

    ;; #L555 - series expansion for results close to 1
    (local.set $aw (f64.abs (local.tee $w (f64.sub (local.get $x) (f64.const 1)))))
    (local.set $ay (f64.abs (local.get $y)))
    (local.set $ya (f64.abs (local.tee $wy (f64.mul (local.get $w) (local.get $y)))))
    ;; #L560 ((aw <= 1.0e-3 && ay <= 1.0) || (ya <= 1.0e-3 && ay >= 1.0))
    (block $or (result i32)
      (if (f64.le (local.get $aw) (f64.const 1.0e-3)) ;; (aw <= 1.0e-3 && ay <= 1.0)
        (then (if (f64.le (local.get $ay) (f64.const 1.0)) (then (i32.const 1) (br $or)))))
      (if (f64.le (local.get $ya) (f64.const 1.0e-3)) ;; (ya <= 1.0e-3 && ay >= 1.0)
        (then (if (f64.ge (local.get $ay) (f64.const 1)) (then (i32.const 1) (br $or)))))
      (i32.const 0)) ;; false
    if ;; if $or block true 
      ;; (((((w*(y-5.)/720. + 1./120.)*w*(y-4.) + 1./24.)*w*(y-3.) + 1./6.)*w*(y-2.) + 0.5)*w*(y-1.) )*wy + wy + 1.
      (;    ( ( ( ( (w * (y-5.)/720. + 1./120.
                ) * w * (y-4.) + 1./24.
              ) * w * (y-3.) + 1./6.
            ) * w * (y-2.) + 0.5
          ) * w * (y-1.)
        ) * wy + wy + 1.                   ;)
      (f64.add 
        (f64.mul (local.get $w) (f64.div (f64.sub (local.get $y) (f64.const 5)) (f64.const 720)))
        (f64.div (f64.const 1) (f64.const 120)))
      (f64.mul (local.get $w) (f64.sub (local.get $y) (f64.const 4)))
      f64.mul
      (f64.div (f64.const 1) (f64.const 24)) f64.add
      (f64.mul (local.get $w) (f64.sub (local.get $y) (f64.const 3)))
      f64.mul
      (f64.div (f64.const 1) (f64.const 6)) f64.add
      (f64.mul (local.get $w) (f64.sub (local.get $y) (f64.const 2)))
      f64.mul
      (f64.const 0.5) f64.add
      (f64.mul (local.get $w) (f64.sub (local.get $y) (f64.const 1)))
      f64.mul
      (local.get $wy) f64.mul
      (local.get $wy) f64.add (f64.const 1) f64.add
      (local.set $z)
      ;; #L565 goto done (#L730) -> 'Negate if odd integer power of negative number'
      (if (local.get $nflg)
        (then (if (local.get $yoddint)
          (then (if (f64.eq (local.get $z) (f64.const 0))
            (then (f64.const -0) return)
            (else (f64.neg (local.get $z)) return)))
          (else (local.get $z) return)))
        (else (local.get $z) return))
    end ;; end $or block true

    ;; #L591 'separate significand from exponent'
    (call $frexp (local.get $x))
    (local.set $e)
    (local.set $x)

    ;; #L600 'find significand of x in antilog table A[]'
    (local.set $i (i32.const 1))
    (if (f64.le (local.get $x) (call $_load (local.get $A_addr) (i32.const 9)))
      (then (local.set $i (i32.const 9))))
    (if (f64.le (local.get $x) (call $_load (local.get $A_addr) (i32.add (local.get $i) (i32.const 4))))
      (then (local.set $i (i32.add (local.get $i) (i32.const 4)))))
    (if (f64.le (local.get $x) (call $_load (local.get $A_addr) (i32.add (local.get $i) (i32.const 2))))
      (then (local.set $i (i32.add (local.get $i) (i32.const 2)))))
    (if (f64.ge (local.get $x) (call $_load (local.get $A_addr) (i32.const 1)))
      (then (local.set $i (i32.const -1))))
    (local.set $i (i32.add (local.get $i) (i32.const 1)))

    ;; #L620
    (f64.sub (local.get $x) (call $_load (local.get $A_addr) (local.get $i)))
    (f64.sub (call $_load (local.get $B_addr) (i32.div_s (local.get $i) (i32.const 2))))
    (local.tee $x (f64.div (call $_load (local.get $A_addr) (local.get $i))))
    (local.tee $z (f64.mul (local.get $x))) ;; #L629, z on stack
    ;; polevl( x, P, 3 )
    (local.set $_N (i32.const 3))
    (local.set $_polans (f64.load align=8 (local.tee $_ptr (local.get $P_addr))))
    (loop $polevl
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $polevl))
    (f64.mul (local.get $_polans)) ;; z * polevl
    ;; plevl( x, Q, 4)
    (local.set $_N (i32.const 3)) ;; plevl uses N-1
    (local.set $_polans (f64.add (local.get $x) (f64.load align=8 (local.tee $_ptr (local.get $Q_addr)))))
    (loop $plevl
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $plevl))
    (f64.div (local.get $_polans)) ;; z * polevl / plevl
    (f64.mul (local.get $x))
    (local.tee $w (f64.sub (call $ldexp (local.get $z) (i32.const -1)))) ;; #L630-631
    (f64.mul (local.get $LOG2EA))
    (f64.add (local.get $w))
    (f64.add (f64.mul (local.get $LOG2EA) (local.get $x)))
    (local.set $z (f64.add (local.get $x))) ;; #L643

    ;; #L646-699
    (local.tee $w (f64.add 
      (f64.convert_i32_s (local.get $e))
      (call $ldexp (f64.neg (f64.convert_i32_s (local.get $i))) (i32.const -4))))
    (local.tee $yb (f64.sub (local.get $y) (local.tee $ya (call $reduc (local.get $y)))))
    f64.mul ;; #L660 w * yb
    (local.tee $W (f64.add (f64.mul (local.get $z) (local.get $y))))
    (local.tee $Wa (call $reduc (local.get $W)))
    f64.sub  ;; #L662 F - Fa
    (local.tee $Wb) ;; Fb on the stack
    (local.tee $W (f64.add (local.get $Wa) (f64.mul (local.get $w) (local.get $ya))))
    (local.tee $Wa (call $reduc (local.get $W)))
    f64.sub ;; #L666 G - Ga
    (local.tee $u) ;; Gb on the stack
    f64.add ;; Fb + Gb, stack clear
    (local.tee $W) ;; #L668, H
    (local.tee $w (call $ldexp (f64.add (local.get $Wa) (local.tee $Wb (call $reduc))) (i32.const 4))) ;; #L670

    (if (f64.gt (local.get $MEXP)) ;; $L673
      (then (if (local.get $nflg)
        (then (if (local.get $yoddint)
          (then (f64.const -inf) return)
          (else (f64.const inf) return)))
        (else (f64.const inf) return))))

    (if (f64.lt (local.get $w) (f64.sub (local.get $MNEXP) (f64.const 1))) ;; #L689
      (then (if (local.get $nflg) 
        (then (if (local.get $yoddint) 
          (then (f64.const -0) return)
          (else (f64.const 0) return)))
        (else (f64.const 0) return))))

    (local.set $e (i32.trunc_f64_s (local.get $w)))
    (local.tee $Wb (f64.sub (local.get $W) (local.get $Wb))) ;; #L702
    (if (f64.gt (f64.const 0)) (then
      (local.set $e (i32.add (local.get $e) (i32.const 1)))
      (local.set $Wb (f64.sub (local.get $Wb) (f64.const 0.0625)))))

    ;; #L715 polevl( Hb, R, 6 )
    (local.get $Wb)
    (local.set $_N (i32.const 6))
    (local.set $_polans (f64.load align=4 (local.tee $_ptr (local.get $R_addr))))
    (loop $polevl
      (f64.mul (local.get $_polans) (local.get $Wb))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $polevl))
    (local.set $z (f64.mul (local.get $_polans))) ;; Hb * polevl

    (local.tee $i (select (i32.const 0) (i32.const 1) (i32.lt_s (local.get $e) (i32.const 0)))) ;; #L720
    (local.tee $i (i32.add (i32.div_s (local.get $e) (i32.const 16)))) ;; #L724 i = e/16 + i;
    (local.tee $e (i32.sub (local.get $e (i32.mul (i32.const 16)))))
    (local.tee $w (call $_load (local.get $A_addr))) ;; douba(e)
    (local.tee $z (f64.add (f64.mul (local.get $z)) (local.get $w))) ;; #L727
    (local.set $z (call $ldexp (local.get $i)))    

    (if (local.get $nflg) ;; #L730-743
      (then (if (local.get $yoddint)
        (then (if (f64.eq (local.get $z) (f64.const 0))
          (then (f64.const -0) return)
          (else (f64.neg (local.get $z)) return))))))
    
    (local.get $z)
  )
  
  (func $sin (export "sin") (param $x f64) (result f64)
    (local $y f64)
    (local $z f64)
    (local $zz f64)
    (local $j i32)
    (local $sign i32)
    (local $_ptr i32)
    (local $_N i32)
    (local $_polans f64)

    (local $DP1 f64)
    (local $DP2 f64)
    (local $DP3 f64)
    (local $lossth f64)
    (local $PIO4 f64)
    (local $sincof_addr i32)
    (local $coscof_addr i32)
    (local.set $DP1 (f64.const 7.85398125648498535156E-1))
    (local.set $DP2 (f64.const 3.77489470793079817668E-8))
    (local.set $DP3 (f64.const 2.69515142907905952645E-15))
    (local.set $lossth (f64.const 1.073741824e9))
    (local.set $PIO4 (f64.const 7.85398163397448309616E-1))
    (local.set $sincof_addr (i32.const 160))
    (local.set $coscof_addr (i32.const 208))

    (if (f64.eq (local.get $x) (f64.const 0)) (then (local.get $x) return))
    (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) return)) ;; isnan(x)
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32))) ;; isfinite(x)
    (i32.ne (i32.and (i32.const 0x7ff00000)) (i32.const 0x7ff00000))
    (if (i32.eqz) (then (f64.const nan) return)) ;; x not finite

    (if (f64.lt (local.get $x) (f64.const 0))
      (then (local.set $x (f64.neg (local.get $x))) (local.set $sign (i32.const -1))) 
      (else (local.set $sign (i32.const 1))))
    
    (if (f64.gt (local.get $x) (local.get $lossth)) (then (f64.const 0) return))

    (local.tee $y (f64.floor (f64.div (local.get $x) (local.get $PIO4))))
    (local.tee $j (i32.trunc_f64_s 
      (f64.sub
        (local.get $y)
        (call $ldexp (f64.floor (call $ldexp (i32.const -4))) (i32.const 4)))))
    (if (i32.and (i32.const 1)) (then 
      (local.set $j (i32.add (local.get $j) (i32.const 1))) 
      (local.set $y (f64.add (local.get $y) (f64.const 1)))))
    (local.tee $j (i32.and (local.get $j) (i32.const 7)))
    (if (i32.gt_s (i32.const 3)) (then 
      (local.set $sign (i32.sub (i32.const 0) (local.get $sign)))
      (local.set $j (i32.sub (local.get $j) (i32.const 4)))))
    
    (local.tee $z 
      (f64.sub
        (f64.sub
          (f64.sub 
            (local.get $x) 
            (f64.mul (local.get $y) (local.get $DP1)))
          (f64.mul (local.get $y) (local.get $DP2)))
        (f64.mul (local.get $y) (local.get $DP3))))
    (local.set $zz (f64.mul (local.get $z)))

    (if (i32.or (i32.eq (local.get $j) (i32.const 1)) (i32.eq (local.get $j) (i32.const 2)))
      (then
        ;; polevl(zz, coscof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (local.get $coscof_addr))))
        (loop $polevl
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          (local.set $_polans (f64.add (f64.load align=8)))
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          (br_if $polevl))
        (local.set $y
          (f64.add
            (f64.sub (f64.const 1) (call $ldexp (local.get $zz) (i32.const -1)))
            (f64.mul (local.get $zz) (f64.mul (local.get $zz) (local.get $_polans)
      )))))
      (else
        ;; polevl(zz, sincof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (local.get $sincof_addr))))
        (loop $polevl
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          (local.set $_polans (f64.add (f64.load align=8)))
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          (br_if $polevl))
        (local.set $y
          (f64.add (local.get $z)
            (f64.mul (local.get $z)
              (f64.mul (local.get $z)
                (f64.mul (local.get $z) (local.get $_polans))
      ))))))

    ;; change sign if needed
    (if (i32.lt_s (local.get $sign) (i32.const 0)) (then (local.set $y (f64.neg (local.get $y)))))

    (local.get $y)
  )

  (func $cos (export "cos") (param $x f64) (result f64)
    (local $y f64)
    (local $z f64)
    (local $zz f64)
    (local $j i32)
    (local $sign i32)
    (local $_ptr i32)
    (local $_N i32)
    (local $_polans f64)

    (local $DP1 f64)
    (local $DP2 f64)
    (local $DP3 f64)
    (local $lossth f64)
    (local $PIO4 f64)
    (local $sincof_addr i32)
    (local $coscof_addr i32)
    (local.set $DP1 (f64.const 7.85398125648498535156E-1))
    (local.set $DP2 (f64.const 3.77489470793079817668E-8))
    (local.set $DP3 (f64.const 2.69515142907905952645E-15))
    (local.set $lossth (f64.const 1.073741824e9))
    (local.set $PIO4 (f64.const 7.85398163397448309616E-1))
    (local.set $sincof_addr (i32.const 160))
    (local.set $coscof_addr (i32.const 208))

    (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) return)) ;; isnan(x)
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32))) ;; isfinite(x)
    (i32.ne (i32.and (i32.const 0x7ff00000)) (i32.const 0x7ff00000))
    (if (i32.eqz) (then (f64.const nan) return)) ;; x not finite

    (local.set $sign (i32.const 1))
    (if (f64.lt (local.get $x) (f64.const 0)) (then (local.set $x (f64.neg (local.get $x)))))

    (if (f64.gt (local.get $x) (local.get $lossth)) (then (f64.const 0) return))

    (local.tee $y (f64.floor (f64.div (local.get $x) (local.get $PIO4))))
    (local.tee $j (i32.trunc_f64_s 
      (f64.sub
        (local.get $y)
        (call $ldexp (f64.floor (call $ldexp (i32.const -4))) (i32.const 4)))))
    (if (i32.and (i32.const 1)) (then 
      (local.set $j (i32.add (local.get $j) (i32.const 1))) 
      (local.set $y (f64.add (local.get $y) (f64.const 1)))))
    (local.tee $j (i32.and (local.get $j) (i32.const 7)))
    (if (i32.gt_s (i32.const 3)) (then 
      (local.set $sign (i32.sub (i32.const 0) (local.get $sign)))
      (local.set $j (i32.sub (local.get $j) (i32.const 4)))))

    (if (i32.gt_s (local.get $j) (i32.const 1)) (then (local.set $sign (i32.sub (i32.const 0) (local.get $sign)))))

    (local.tee $z 
      (f64.sub
        (f64.sub
          (f64.sub 
            (local.get $x) 
            (f64.mul (local.get $y) (local.get $DP1)))
          (f64.mul (local.get $y) (local.get $DP2)))
        (f64.mul (local.get $y) (local.get $DP3))))
    (local.set $zz (f64.mul (local.get $z)))

    (if (i32.or (i32.eq (local.get $j) (i32.const 1)) (i32.eq (local.get $j) (i32.const 2)))
      (then
        ;; polevl(zz, sincof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (local.get $sincof_addr))))
        (loop $polevl
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          (local.set $_polans (f64.add (f64.load align=8)))
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          (br_if $polevl))
        (local.set $y
          (f64.add (local.get $z)
            (f64.mul (local.get $z)
              (f64.mul (local.get $z)
                (f64.mul (local.get $z) (local.get $_polans)
      ))))))
      (else
        ;; polevl(zz, coscof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (local.get $coscof_addr))))
        (loop $polevl
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          (local.set $_polans (f64.add (f64.load align=8)))
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          (br_if $polevl))
        (local.set $y
          (f64.add
            (f64.sub (f64.const 1) (call $ldexp (local.get $zz) (i32.const -1)))
            (f64.mul (local.get $zz) (f64.mul (local.get $zz) (local.get $_polans))
      )))))
    
    ;; change sign if needed
    (if (i32.lt_s (local.get $sign) (i32.const 0)) (then (local.set $y (f64.neg (local.get $y)))))

    (local.get $y)
  )

  (func $stirf (param $x f64) (result f64) ;; #L138
    (local $y f64)
    (local $w f64)
    (local $v f64)
    (local $_ptr i32)
    (local $_N i32)
    (local $_polans f64)
    
    (local $MAXGAM f64)
    (local $MAXSTIR f64)
    (local $SQTPI f64)
    (local $STIR_addr i32)
    ;; Modified to match `fastexp` overflow limit
    ;; (local.set $MAXGAM (f64.const 171.624376956302725))
    (local.set $MAXGAM (f64.const 88.72283))
    (local.set $MAXSTIR (f64.const 143.01608))
    (local.set $SQTPI (f64.const 2.50662827463100050242E0))
    (local.set $STIR_addr (i32.const 120))

    (if (f64.ge (local.get $x) (local.get $MAXGAM)) (then (f64.const inf) return))

    (local.tee $w (f64.div (f64.const 1) (local.get $x))) ;; w on stack
    ;; polevl( w, STIR, 4 )
    (local.set $_N (i32.const 4))
    (local.set $_polans (f64.load (local.tee $_ptr (local.get $STIR_addr))))
    (loop $polevl
      (f64.mul (local.get $_polans) (local.get $w))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $polevl))
    (local.set $w (f64.add (f64.const 1) (f64.mul (local.get $_polans)))) ;; 1 + w * polevl

    (local.set $y (f64.promote_f32 (call $fastexp (f32.demote_f64 (local.get $x))))) ;; #L147

    (if (result f64) (f64.gt (local.get $x) (local.get $MAXSTIR))
      (then
        (local.tee $v (call $pow (local.get $x) (f64.sub (f64.mul (local.get $x) (f64.const 0.5)) (f64.const 0.25))))
        (local.tee $y (f64.mul (f64.div (local.get $v) (local.get $y))))) ;; v * v/y
      (else
        (local.tee $y (f64.div (call $pow (local.get $x) (f64.sub (local.get $x) (f64.const 0.5))) (local.get $y)))))

    (f64.mul (f64.mul (local.get $w)) (local.get $SQTPI)) ;; SQTPI * y * w
  )

  (func $gamma (export "gamma") (param $x f64) (result f64) ;; #L160
    (local $p f64)
    (local $q f64)
    (local $z f64)
    (local $sgngam i32) ;; modified in code to just bool if gamma negative or not
    (local $_N i32)
    (local $_ptr i32)
    (local $_polans f64)

    (local $M_PI f64)
    (local $P_addr i32)
    (local $Q_addr i32)
    (local.set $M_PI (f64.const 3.14159265358979323846))
    (local.set $P_addr (i32.const 0))
    (local.set $Q_addr (i32.const 56))

    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32))) ;; isfinite(x)
    (i32.ne (i32.and (i32.const 0x7ff00000)) (i32.const 0x7ff00000))
    (if (i32.eqz) (then (local.get $x) return)) ;; x not finite

    (if (f64.gt (local.tee $q (f64.abs (local.get $x))) (f64.const 33)) (then 
      (if (f64.lt (local.get $x) (f64.const 0)) 
        (then
          (local.tee $p (f64.floor (local.get $q)))
          (if (f64.eq (local.get $q)) (then (f64.const inf) return))
          (if (i32.eqz (i32.and (i32.trunc_f64_s (local.get $p)) (i32.const 1))) ;; even/odd
            (then (local.set $sgngam (i32.const 1))))
          (if (f64.gt (local.tee $z (f64.sub (local.get $q) (local.get $p))) (f64.const 0.5))
            (then (local.set $z (f64.sub (local.get $q) (f64.add (local.get $p) (f64.const 1))))))
          (local.tee $z (f64.mul (local.get $q) (call $sin (f64.mul (local.get $M_PI) (local.get $z)))))
          (if (f64.eq (f64.const 0))
            (then (if (local.get $sgngam) 
              (then (f64.const -inf) return) 
              (else (f64.const inf) return))))
          (local.set $z (f64.div (local.get $M_PI) (f64.mul (f64.abs (local.get $z)) (call $stirf (local.get $q))))))
        (else (local.set $z (call $stirf (local.get $x)))))
      (if (local.get $sgngam)
        (then (f64.neg (local.get $z)) return)
        (else (local.get $z) return))))

    (local.set $z (f64.const 1))
    (if (f64.ge (local.get $x) (f64.const 3)) (then
      (loop $while
        (local.tee $x (f64.sub (local.get $x) (f64.const 1)))
        (local.set $z (f64.mul (local.get $z)))
        (f64.ge (local.get $x) (f64.const 3))
        (br_if $while))))
    
    (if (f64.lt (local.get $x) (f64.const 0)) (then
      (loop $while
        (if (f64.gt (local.get $x) (f64.const -1E-9)) 
          (then (if (f64.eq (local.get $x) (f64.const 0)) 
            (then (f64.const inf) return) 
            (else (f64.div 
              (local.get $z) 
              (f64.mul (local.get $x) 
                (f64.add (f64.const 1) 
                  (f64.mul (local.get $x) (f64.const 0.5772156649015329)))))
              return))))
        (local.set $z (f64.div (local.get $z) (local.get $x)))
        (local.set $x (f64.add (local.get $x) (f64.const 1)))
        (f64.lt (local.get $x) (f64.const 0))
        (br_if $while))))

    (if (f64.lt (local.get $x) (f64.const 2)) (then
      (loop $while
        (if (f64.lt (local.get $x) (f64.const 1E-9)) 
          (then (if (f64.eq (local.get $x) (f64.const 0)) 
            (then (f64.const inf) return) 
            (else (f64.div 
              (local.get $z) 
              (f64.mul (local.get $x) 
                (f64.add (f64.const 1) 
                  (f64.mul (local.get $x) (f64.const 0.5772156649015329)))))
              return))))
        (local.set $z (f64.div (local.get $z) (local.get $x)))
        (local.set $x (f64.add (local.get $x) (f64.const 1)))
        (f64.lt (local.get $x) (f64.const 2))
        (br_if $while))))

    (if (f64.eq (local.get $x) (f64.const 2)) (then (local.get $z) return))

    (local.set $x (f64.sub (local.get $x) (f64.const 2)))
    ;; p = polevl(x, P, 6)
    (local.set $_N (i32.const 6))
    (local.set $_polans (f64.load align=8 (local.tee $_ptr (local.get $P_addr))))
    (loop $polevl
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $polevl))
    (f64.mul (local.get $z) (local.get $_polans)) ;; z * p on the stack
    ;; q = polevl(x, Q, 7)
    (local.set $_N (i32.const 7))
    (local.set $_polans (f64.load align=8 (local.tee $_ptr (local.get $Q_addr))))
    (loop $polevl
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      (local.set $_polans (f64.add (f64.load align=8)))
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      (br_if $polevl))

    (f64.div (local.get $_polans)) ;; return z * p / q
  )
)