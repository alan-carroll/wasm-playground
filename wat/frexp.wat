(module
  ;; https://www.netlib.org/fdlibm/s_frexp.c

  (global $two54 f64 (f64.const 1.80143985094819840000e+16))

  (func $frexp (export "frexp") (param $x f64) (result f64 i32)
    (local $hx i32)
    (local $lx i32)
    (local $ix i32)
    (local $exp i32)
    (local $_x i64)
    
    (block $ret (result f64 i32)
      (local.set $exp (i32.const 0))

      (local.tee $_x (i64.reinterpret_f64 (local.get $x)))
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      local.set $hx

      local.get $_x
      i32.wrap_i64
      local.set $lx

      (local.tee $ix (i32.and (i32.const 0x7fffffff) (local.get $hx)))
      i32.const 0x7ff00000 ;; Check for 0/inf/nan
      i32.ge_s
      local.get $ix
      local.get $lx
      i32.or
      i32.eqz
      i32.or
      if
        local.get $x
        local.get $exp
        br $ret
      end
      
      ;; Check if subnormal
      (i32.lt_s (local.get $ix) (i32.const 0x00100000))
      if
        (f64.mul (local.get $x) (global.get $two54))
        i64.reinterpret_f64
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        local.set $hx
        (local.set $ix (i32.and (local.get $hx) (i32.const 0x7fffffff)))
        (local.set $exp (i32.const -54))
      end

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
      f64.reinterpret_i64 ;; x
      local.get $exp) ;; end $ret
  )
)
