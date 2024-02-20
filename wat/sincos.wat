(module

  ;; https://www.netlib.org/cephes/ cmath sin.c

  (memory 1)

  (global $sincof_addr i32 (i32.const 0))
  (global $coscof_addr i32 (i32.const 48))

  (global $DP1 f64 (f64.const 7.85398125648498535156E-1))
  (global $DP2 f64 (f64.const 3.77489470793079817668E-8))
  (global $DP3 f64 (f64.const 2.69515142907905952645E-15))
  (global $lossth f64 (f64.const 1.073741824e9))
  (global $PIO4 f64 (f64.const 7.85398163397448309616E-1))

  ;; ldexp
  (global $two54 f64 (f64.const 1.80143985094819840000e+16))
  (global $twom54 f64 (f64.const 5.55111512312578270212e-17))

  (start $init)

  (func $_store (param $addr i32) (param $off i32) (param $val f64)
    (f64.store (i32.add 
      (local.get $addr) 
      (i32.mul (local.get $off) (i32.const 8)))
      (local.get $val))
  )

  (func $init
    ;; Store P array
    (call $_store (global.get $sincof_addr) (i32.const 0) (f64.const  1.58962301576546568060E-10))
    (call $_store (global.get $sincof_addr) (i32.const 1) (f64.const -2.50507477628578072866E-8))
    (call $_store (global.get $sincof_addr) (i32.const 2) (f64.const  2.75573136213857245213E-6))
    (call $_store (global.get $sincof_addr) (i32.const 3) (f64.const -1.98412698295895385996E-4))
    (call $_store (global.get $sincof_addr) (i32.const 4) (f64.const  8.33333333332211858878E-3))
    (call $_store (global.get $sincof_addr) (i32.const 5) (f64.const -1.66666666666666307295E-1))

    ;; Store Q array
    (call $_store (global.get $coscof_addr) (i32.const 0) (f64.const -1.13585365213876817300E-11))
    (call $_store (global.get $coscof_addr) (i32.const 1) (f64.const  2.08757008419747316778E-9))
    (call $_store (global.get $coscof_addr) (i32.const 2) (f64.const -2.75573141792967388112E-7))
    (call $_store (global.get $coscof_addr) (i32.const 3) (f64.const  2.48015872888517045348E-5))
    (call $_store (global.get $coscof_addr) (i32.const 4) (f64.const -1.38888888888730564116E-3))
    (call $_store (global.get $coscof_addr) (i32.const 5) (f64.const  4.16666666666665929218E-2))

  )

  (func $ldexp (param $x f64) (param $n i32) (result f64)
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

  (func $sin (export "sin") (param $x f64) (result f64)
    (local $y f64)
    (local $z f64)
    (local $zz f64)
    (local $j i32)
    (local $sign i32)
    (local $_ptr i32)
    (local $_N i32)
    (local $_polans f64)

    (if (f64.eq (local.get $x) (f64.const 0)) (then (local.get $x) return))
    (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) return)) ;; isnan(x)
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32))) ;; isfinite(x)
    (i32.and (i32.const 0x7ff00000))
    (i32.ne (i32.const 0x7ff00000))
    (if (i32.eqz) (then (f64.const nan) return)) ;; x not finite

    (if (f64.lt (local.get $x) (f64.const 0))
      (then (local.set $x (f64.neg (local.get $x))) (local.set $sign (i32.const -1))) 
      (else (local.set $sign (i32.const 1))))
    
    (if (f64.gt (local.get $x) (global.get $lossth)) (then (f64.const 0) return))

    (local.tee $y (f64.floor (f64.div (local.get $x) (global.get $PIO4))))
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
            (f64.mul (local.get $y) (global.get $DP1)))
          (f64.mul (local.get $y) (global.get $DP2)))
        (f64.mul (local.get $y) (global.get $DP3))))
    (local.set $zz (f64.mul (local.get $z)))

    (if (i32.or (i32.eq (local.get $j) (i32.const 1)) (i32.eq (local.get $j) (i32.const 2)))
      (then
        ;; polevl(zz, coscof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (global.get $coscof_addr))))
        (loop $coscof_loop
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          f64.load
          f64.add
          (local.set $_polans)
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          br_if $coscof_loop)
        (local.set $y
          (f64.add
            (f64.sub 
              (f64.const 1)
              (call $ldexp (local.get $zz) (i32.const -1)))
            (f64.mul
              (local.get $zz)
              (f64.mul
                (local.get $zz)
                (local.get $_polans)
      )))))
      (else
        ;; polevl(zz, sincof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (global.get $sincof_addr))))
        (loop $sincof_loop
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          f64.load
          f64.add
          (local.set $_polans)
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          br_if $sincof_loop)
        (local.set $y
          (f64.add
            (local.get $z)
            (f64.mul 
              (local.get $z)
              (f64.mul 
                (local.get $z)
                (f64.mul 
                  (local.get $z)
                  (local.get $_polans)
      )))))))

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

    (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) return)) ;; isnan(x)
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32))) ;; isfinite(x)
    (i32.and (i32.const 0x7ff00000))
    (i32.ne (i32.const 0x7ff00000))
    (if (i32.eqz) (then (f64.const nan) return)) ;; x not finite

    (local.set $sign (i32.const 1))
    (if (f64.lt (local.get $x) (f64.const 0)) (then (local.set $x (f64.neg (local.get $x)))))

    (if (f64.gt (local.get $x) (global.get $lossth)) (then (f64.const 0) return))

    (local.tee $y (f64.floor (f64.div (local.get $x) (global.get $PIO4))))
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
            (f64.mul (local.get $y) (global.get $DP1)))
          (f64.mul (local.get $y) (global.get $DP2)))
        (f64.mul (local.get $y) (global.get $DP3))))
    (local.set $zz (f64.mul (local.get $z)))

    (if (i32.or (i32.eq (local.get $j) (i32.const 1)) (i32.eq (local.get $j) (i32.const 2)))
      (then
        ;; polevl(zz, sincof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (global.get $sincof_addr))))
        (loop $sincof_loop
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          f64.load
          f64.add
          (local.set $_polans)
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          br_if $sincof_loop)
        (local.set $y
          (f64.add
            (local.get $z)
            (f64.mul 
              (local.get $z)
              (f64.mul 
                (local.get $z)
                (f64.mul 
                  (local.get $z)
                  (local.get $_polans)
      ))))))
      (else
        ;; polevl(zz, coscof, 5)
        (local.set $_N (i32.const 5))
        (local.set $_polans (f64.load (local.tee $_ptr (global.get $coscof_addr))))
        (loop $coscof_loop
          (f64.mul (local.get $_polans) (local.get $zz))
          (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
          f64.load
          f64.add
          (local.set $_polans)
          (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
          br_if $coscof_loop)
        (local.set $y
          (f64.add
            (f64.sub 
              (f64.const 1)
              (call $ldexp (local.get $zz) (i32.const -1)))
            (f64.mul
              (local.get $zz)
              (f64.mul
                (local.get $zz)
                (local.get $_polans)
      ))))))
    
    ;; change sign if needed
    (if (i32.lt_s (local.get $sign) (i32.const 0)) (then (local.set $y (f64.neg (local.get $y)))))

    (local.get $y)
  )
)