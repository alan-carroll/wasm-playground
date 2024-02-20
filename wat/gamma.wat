(module
  ;; https://github.com/scipy/scipy/blob/main/scipy/special/cephes/gamma.c
  ;; Modified from f64 to f32 since `fastexp` overflow limit < MAXGAM

  (import "fast_exp" "fastexp" (func $fastexp (param f32) (result f32)))
  (import "pow_funcs" "pow" (func $pow (param f64 f64) (result f64)))
  (import "sincos" "sin" (func $sin (param f64) (result f64)))
  (import "sincos" "cos" (func $cos (param f64) (result f64)))

  (memory 1)

  ;; polynomial arrays
  (global $P_addr i32 (i32.const 0))
  (global $P_count i32 (i32.const 7))
  (global $Q_addr i32 (i32.const 56)) ;; 0 + 7*8 = 56
  (global $Q_count i32 (i32.const 8))
  (global $STIR_addr i32 (i32.const 120)) ;; 56 + 8*8 = 120
  (global $STIR_count i32 (i32.const 5))

  ;; Modified to match `fastexp` overflow limit
  ;; (global $MAXGAM f64 (f64.const 171.624376956302725))
  (global $MAXGAM f64 (f64.const 88.72283))
  (global $LOGPI f64 (f64.const 1.14472988584940017414))
  (global $MAXSTIR f64 (f64.const 143.01608))
  (global $SQTPI f64 (f64.const 2.50662827463100050242E0))
  (global $MAXLOG f64 (f64.const 7.09782712893383996732E2))
  (global $M_PI f64 (f64.const 3.14159265358979323846))

  (start $init)

  (func $_store (param $addr i32) (param $off i32) (param $val f64)
    (f64.store (i32.add 
      (local.get $addr) 
      (i32.mul (local.get $off) (i32.const 8)))
      (local.get $val))
  )

  (func $init
    ;; Store P array
    (call $_store (global.get $P_addr) (i32.const 0) (f64.const 1.60119522476751861407E-4))
    (call $_store (global.get $P_addr) (i32.const 1) (f64.const 1.19135147006586384913E-3))
    (call $_store (global.get $P_addr) (i32.const 2) (f64.const 1.04213797561761569935E-2))
    (call $_store (global.get $P_addr) (i32.const 3) (f64.const 4.76367800457137231464E-2))
    (call $_store (global.get $P_addr) (i32.const 4) (f64.const 2.07448227648435975150E-1))
    (call $_store (global.get $P_addr) (i32.const 5) (f64.const 4.94214826801497100753E-1))
    (call $_store (global.get $P_addr) (i32.const 6) (f64.const 9.99999999999999996796E-1))

    ;; Store Q array
    (call $_store (global.get $Q_addr) (i32.const 0) (f64.const -2.31581873324120129819E-5))
    (call $_store (global.get $Q_addr) (i32.const 1) (f64.const 5.39605580493303397842E-4))
    (call $_store (global.get $Q_addr) (i32.const 2) (f64.const -4.45641913851797240494E-3))
    (call $_store (global.get $Q_addr) (i32.const 3) (f64.const 1.18139785222060435552E-2))
    (call $_store (global.get $Q_addr) (i32.const 4) (f64.const 3.58236398605498653373E-2))
    (call $_store (global.get $Q_addr) (i32.const 5) (f64.const -2.34591795718243348568E-1))
    (call $_store (global.get $Q_addr) (i32.const 6) (f64.const 7.14304917030273074085E-2))
    (call $_store (global.get $Q_addr) (i32.const 7) (f64.const 1.00000000000000000320E0))

    ;; Store STIR array
    (call $_store (global.get $STIR_addr) (i32.const 0) (f64.const 7.87311395793093628397E-4))
    (call $_store (global.get $STIR_addr) (i32.const 1) (f64.const -2.29549961613378126380E-4))
    (call $_store (global.get $STIR_addr) (i32.const 2) (f64.const -2.68132617805781232825E-3))
    (call $_store (global.get $STIR_addr) (i32.const 3) (f64.const 3.47222221605458667310E-3))
    (call $_store (global.get $STIR_addr) (i32.const 4) (f64.const 8.33333333333482257126E-2))
  )

  (func $stirf (param $x f64) (result f64) ;; #L138
    (local $y f64)
    (local $w f64)
    (local $v f64)
    (local $_ptr i32)
    (local $_N i32)
    (local $_polans f64)

    (block $ret (result f64)
      (f64.ge (local.get $x) (global.get $MAXGAM)) if (f64.const inf) (br $ret) end

      (local.tee $w (f64.div (f64.const 1) (local.get $x))) ;; w on stack
      ;; polevl( w, STIR, 4 )
      (local.set $_N (i32.const 4))
      (local.set $_polans (f64.load (local.tee $_ptr (global.get $STIR_addr))))
      (loop $STIR_coef_loop
        (f64.mul (local.get $_polans) (local.get $w))
        (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
        f64.load
        f64.add
        (local.set $_polans)
        (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
        br_if $STIR_coef_loop)
      (local.get $_polans)
      f64.mul ;; w * polevl
      (f64.const 1)
      f64.add
      (local.set $w)

      (local.set $y (f64.promote_f32 (call $fastexp (f32.demote_f64 (local.get $x))))) ;; #L147
      (f64.gt (local.get $x) (global.get $MAXSTIR))
      if (result f64)
        (local.tee $v (call $pow (local.get $x) (f64.sub (f64.mul (local.get $x) (f64.const 0.5)) (f64.const 0.25))))
        (f64.div (local.get $v) (local.get $y))
        f64.mul ;; v * v/y
        (local.tee $y)
      else 
        (local.tee $y (f64.div (call $pow (local.get $x) (f64.sub (local.get $x) (f64.const 0.5))) (local.get $y)))
      end
      (local.get $w)
      f64.mul
      (global.get $SQTPI)
      f64.mul ;; SQTPI * y * w
    ) ;; end $ret
  )

  (func $gamma (export "gamma") (param $x f64) (result f64) ;; #L160
    (local $p f64)
    (local $q f64)
    (local $z f64)
    (local $sgngam i32) ;; modified in code to just bool if gamma negative or not
    (local $_N i32)
    (local $_ptr i32)
    (local $_polans f64)

    ;; isfinite(x) - checks +/- inf and nan
    (i32.wrap_i64 (i64.shr_s (i64.reinterpret_f64 (local.get $x)) (i64.const 32)))
    (i32.and (i32.const 0x7ff00000))
    (i32.ne (i32.const 0x7ff00000))
    i32.eqz if (local.get $x) return end ;; x not finite

    (f64.gt (local.tee $q (f64.abs (local.get $x))) (f64.const 33))
    if
      (if (f64.lt (local.get $x) (f64.const 0)) (then
        (local.tee $p (f64.floor (local.get $q)))
        (if (f64.eq (local.get $q)) (then (f64.const inf) return))
        (if (i32.eqz (i32.and (i32.trunc_f64_s (local.get $p)) (i32.const 1))) ;; even/odd
          (then (local.set $sgngam (i32.const 1))))
        (if (f64.gt (local.tee $z (f64.sub (local.get $q) (local.get $p))) (f64.const 0.5))
          (then (local.set $z (f64.sub (local.get $q) (f64.add (local.get $p) (f64.const 1))))))
        (local.tee $z (f64.mul (local.get $q) (call $sin (f64.mul (global.get $M_PI) (local.get $z)))))
        (if (f64.eq (f64.const 0)) (then 
          (if (local.get $sgngam) 
            (then (f64.const -inf) return) (else (f64.const inf) return))))
        (local.set $z (f64.div 
          (global.get $M_PI) 
          (f64.mul (f64.abs (local.get $z)) (call $stirf (local.get $q)))))
        )
        (else (local.set $z (call $stirf (local.get $x))))
      )
      (if (local.get $sgngam) 
        (then (f64.neg (local.get $z)) return) 
        (else (local.get $z) return))
    end

    (local.set $z (f64.const 1))
    (if (f64.ge (local.get $x) (f64.const 3)) (then
      (loop $z_loop
        (local.tee $x (f64.sub (local.get $x) (f64.const 1)))
        (local.set $z (f64.mul (local.get $z)))
        (f64.ge (local.get $x) (f64.const 3))
        (br_if $z_loop))))
    
    (if (f64.lt (local.get $x) (f64.const 0)) (then
      (loop $z_loop
        (if (f64.gt (local.get $x) (f64.const -1E-9)) 
          (then (if (f64.eq (local.get $x) (f64.const 0)) 
            (then (f64.const inf) return) 
            (else (f64.div 
              (local.get $z) 
              (f64.mul (local.get $x) (f64.add (f64.const 1) (f64.mul 
                (local.get $x) (f64.const 0.5772156649015329)))))
              return)))
        )
        (local.set $z (f64.div (local.get $z) (local.get $x)))
        (local.set $x (f64.add (local.get $x) (f64.const 1)))
        (f64.lt (local.get $x) (f64.const 0))
        (br_if $z_loop))))

    (if (f64.lt (local.get $x) (f64.const 2)) (then
      (loop $z_loop
        (if (f64.lt (local.get $x) (f64.const 1E-9)) 
          (then (if (f64.eq (local.get $x) (f64.const 0)) 
            (then (f64.const inf) return) 
            (else (f64.div 
              (local.get $z) 
              (f64.mul (local.get $x) (f64.add (f64.const 1) (f64.mul 
                (local.get $x) (f64.const 0.5772156649015329)))))
              return)))
        )
        (local.set $z (f64.div (local.get $z) (local.get $x)))
        (local.set $x (f64.add (local.get $x) (f64.const 1)))
        (f64.lt (local.get $x) (f64.const 2))
        (br_if $z_loop))))

    (if (f64.eq (local.get $x) (f64.const 2)) (then (local.get $z) return))

    (local.set $x (f64.sub (local.get $x) (f64.const 2)))
    ;; p = polevl(x, P, 6)
    (local.set $_N (i32.const 6))
    (local.set $_polans (f64.load (local.tee $_ptr (global.get $P_addr))))
    (loop $polevl_loop
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      f64.load
      f64.add
      (local.set $_polans)
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      br_if $polevl_loop)
    (f64.mul (local.get $z) (local.get $_polans)) ;; z * p on the stack
    ;; q = polevl(x, Q, 7)
    (local.set $_N (i32.const 7))
    (local.set $_polans (f64.load (local.tee $_ptr (global.get $Q_addr))))
    (loop $polevl_loop
      (f64.mul (local.get $_polans) (local.get $x))
      (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
      f64.load
      f64.add
      (local.set $_polans)
      (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
      br_if $polevl_loop)

    (f64.div (local.get $_polans)) ;; return z * p / q
  )
)