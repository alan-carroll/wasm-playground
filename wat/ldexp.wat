(module
  ;; https://android.googlesource.com/platform/bionic/+/a27d2baa/libc/bionic/ldexp.c
  ;; https://www.netlib.org/fdlibm/s_ldexp.c
  ;; https://www.netlib.org/fdlibm/s_scalbn.c

  (global $two54 f64 (f64.const 1.80143985094819840000e+16))
  (global $twom54 f64 (f64.const 5.55111512312578270212e-17))

  (func $ldexp (export "ldexp") (param $x f64) (param $n i32) (result f64)
    (local $k i32)
    (local $hx i32)
    (local $lx i32)
    (local $_x i64)

    (block $ret (result f64)
      (local.tee $_x (i64.reinterpret_f64 (local.get $x)))
      i64.const 32
      i64.shr_u
      i32.wrap_i64
      local.set $hx

      local.get $_x
      i32.wrap_i64
      local.set $lx

      ;; extract exponent
      (local.tee $k (i32.shr_u 
        (i32.and (local.get $hx) (i32.const 0x7ff00000)) 
        (i32.const 20)))
      if ;; != 0
      else ;; 0 or subnormal
        (i32.or (local.get $lx) (i32.and (local.get $hx) (i32.const 0x7fffffff)))
        if ;; != 0
          (i32.lt_s (local.get $n) (i32.const -50000))
          if ;; underflow
            (f64.gt (f64.const 0) (local.get $x))
            if
              f64.const 0
              br $ret
            else
              f64.const -0
              br $ret
            end
          else
            (local.tee $x (f64.mul (local.get $x) (global.get $two54)))
            i64.reinterpret_f64
            i64.const 32
            i64.shr_u
            i32.wrap_i64
            local.set $hx
            (local.set $k (i32.sub 
              (i32.shr_u 
                (i32.and (local.get $hx) (i32.const 0x7ff00000)) 
                (i32.const 20))
              (i32.const 54)))
          end
        else ;; == 0
          local.get $x
          br $ret
        end
      end
      (i32.eq (local.get $k) (i32.const 0x7ff))
      if ;; NaN or Inf
        (f64.add (local.get $x) (local.get $x))
        br $ret
      end
      (local.tee $k (i32.add (local.get $k) (local.get $n)))
      i32.const 0x7fe
      i32.gt_s
      if ;; overflow
        (f64.gt (local.get $x) (f64.const 0))
        if
          f64.const inf
          br $ret
        else
          f64.const -inf
          br $ret
        end
      end
      (i32.gt_s (local.get $k) (i32.const 0))
      if ;; normal result
        (i64.or ;; combine high/low bits (SET_HIGH_WORD)
          (i64.and (i64.reinterpret_f64 (local.get $x)) (i64.const 0xFFFFFFFF)) ;; keep low 32 bits
          (i64.shl (i64.extend_i32_u ;; i32 to i64 and shift 32 bits higher
            (i32.or
              (i32.and (local.get $hx) (i32.const 0x800fffff))
              (i32.shl (local.get $k) (i32.const 20))))
            (i64.const 32)))
        f64.reinterpret_i64
        br $ret
      end
      (i32.le_s (local.get $k) (i32.const -54))
      if ;; under or overflow check
        (i32.gt_s (local.get $n) (i32.const 50000))
        if ;; overflow
          (f64.gt (local.get $x) (f64.const 0))
          if
            f64.const inf
            br $ret
          else
            f64.const -inf
            br $ret
          end
        else ;; underflow
          (f64.gt (f64.const 0) (local.get $x))
          if
            f64.const 0
            br $ret
          else
            f64.const -0
            br $ret
          end
        end
      end
      ;; finally -- subnormal result
      (local.set $k (i32.add (local.get $k) (i32.const 54)))
      (i64.or ;; combine high/low bits (SET_HIGH_WORD)
          (i64.and (i64.reinterpret_f64 (local.get $x)) (i64.const 0xFFFFFFFF)) ;; keep low 32 bits
          (i64.shl (i64.extend_i32_u ;; i32 to i64 and shift 32 bits higher
            (i32.or
              (i32.and (local.get $hx) (i32.const 0x800fffff))
              (i32.shl (local.get $k) (i32.const 20))))
            (i64.const 32)))
      f64.reinterpret_i64
      global.get $twom54
      f64.mul) ;; end $ret
  )
)