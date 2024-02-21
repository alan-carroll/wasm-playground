(module
  ;; https://www.netlib.org/fdlibm/s_frexp.c

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
)
