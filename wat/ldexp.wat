(module
  ;; https://android.googlesource.com/platform/bionic/+/a27d2baa/libc/bionic/ldexp.c
  ;; https://www.netlib.org/fdlibm/s_ldexp.c
  ;; https://www.netlib.org/fdlibm/s_scalbn.c

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
)