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

  (memory 1)

  ;; pow arrays
  (global $P_addr i32 (i32.const 0))
  (global $P_count i32 (i32.const 4))
  (global $Q_addr i32 (i32.const 32)) ;; 0 + 4*8 = 32
  (global $Q_count i32 (i32.const 4))
  (global $A_addr i32 (i32.const 64)) ;; 32 + 4*8 = 64
  (global $A_count i32 (i32.const 17))
  (global $B_addr i32 (i32.const 200)) ;; 64 + 17*8 = 200
  (global $B_count i32 (i32.const 9))
  (global $R_addr i32 (i32.const 272)) ;; 200 + 9*8 = 272
  (global $R_count i32 (i32.const 7))
  
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
    ;; Store P array
    (call $_store (global.get $P_addr) (i32.const 0) (f64.const 4.97778295871696322025E-1))
    (call $_store (global.get $P_addr) (i32.const 1) (f64.const 3.73336776063286838734E0))
    (call $_store (global.get $P_addr) (i32.const 2) (f64.const 7.69994162726912503298E0))
    (call $_store (global.get $P_addr) (i32.const 3) (f64.const 4.66651806774358464979E0))

    ;; Store Q array
    (call $_store (global.get $Q_addr) (i32.const 0) (f64.const 9.33340916416696166113E0))
    (call $_store (global.get $Q_addr) (i32.const 1) (f64.const 2.79999886606328401649E1))
    (call $_store (global.get $Q_addr) (i32.const 2) (f64.const 3.35994905342304405431E1))
    (call $_store (global.get $Q_addr) (i32.const 3) (f64.const 1.39995542032307539578E1))

    ;; Store A array
    (call $_store (global.get $A_addr) (i32.const 0) (f64.const 1.00000000000000000000E0))
    (call $_store (global.get $A_addr) (i32.const 1) (f64.const 9.57603280698573700036E-1))
    (call $_store (global.get $A_addr) (i32.const 2) (f64.const 9.17004043204671215328E-1))
    (call $_store (global.get $A_addr) (i32.const 3) (f64.const 8.78126080186649726755E-1))
    (call $_store (global.get $A_addr) (i32.const 4) (f64.const 8.40896415253714502036E-1))
    (call $_store (global.get $A_addr) (i32.const 5) (f64.const 8.05245165974627141736E-1))
    (call $_store (global.get $A_addr) (i32.const 6) (f64.const 7.71105412703970372057E-1))
    (call $_store (global.get $A_addr) (i32.const 7) (f64.const 7.38413072969749673113E-1))
    (call $_store (global.get $A_addr) (i32.const 8) (f64.const 7.07106781186547572737E-1))
    (call $_store (global.get $A_addr) (i32.const 9) (f64.const 6.77127773468446325644E-1))
    (call $_store (global.get $A_addr) (i32.const 10) (f64.const 6.48419777325504820276E-1))
    (call $_store (global.get $A_addr) (i32.const 11) (f64.const 6.20928906036742001007E-1))
    (call $_store (global.get $A_addr) (i32.const 12) (f64.const 5.94603557501360513449E-1))
    (call $_store (global.get $A_addr) (i32.const 13) (f64.const 5.69394317378345782288E-1))
    (call $_store (global.get $A_addr) (i32.const 14) (f64.const 5.45253866332628844837E-1))
    (call $_store (global.get $A_addr) (i32.const 15) (f64.const 5.22136891213706877402E-1))
    (call $_store (global.get $A_addr) (i32.const 16) (f64.const 5.00000000000000000000E-1))

    ;; Store B array
    (call $_store (global.get $B_addr) (i32.const 0) (f64.const 0.00000000000000000000E0))
    (call $_store (global.get $B_addr) (i32.const 1) (f64.const 1.64155361212281360176E-17))
    (call $_store (global.get $B_addr) (i32.const 2) (f64.const 4.09950501029074826006E-17))
    (call $_store (global.get $B_addr) (i32.const 3) (f64.const 3.97491740484881042808E-17))
    (call $_store (global.get $B_addr) (i32.const 4) (f64.const -4.83364665672645672553E-17))
    (call $_store (global.get $B_addr) (i32.const 5) (f64.const 1.26912513974441574796E-17))
    (call $_store (global.get $B_addr) (i32.const 6) (f64.const 1.99100761573282305549E-17))
    (call $_store (global.get $B_addr) (i32.const 7) (f64.const -1.52339103990623557348E-17))
    (call $_store (global.get $B_addr) (i32.const 8) (f64.const 0.00000000000000000000E0))

    ;; Store R array
    (call $_store (global.get $R_addr) (i32.const 0) (f64.const 1.49664108433729301083E-5))
    (call $_store (global.get $R_addr) (i32.const 1) (f64.const 1.54010762792771901396E-4))
    (call $_store (global.get $R_addr) (i32.const 2) (f64.const 1.33335476964097721140E-3))
    (call $_store (global.get $R_addr) (i32.const 3) (f64.const 9.61812908476554225149E-3))
    (call $_store (global.get $R_addr) (i32.const 4) (f64.const 5.55041086645832347466E-2))
    (call $_store (global.get $R_addr) (i32.const 5) (f64.const 2.40226506959099779976E-1))
    (call $_store (global.get $R_addr) (i32.const 6) (f64.const 6.93147180559945308821E-1))
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
    (local.set $P_addr (global.get $P_addr))
    (local.set $Q_addr (global.get $Q_addr))
    (local.set $A_addr (global.get $A_addr))
    (local.set $B_addr (global.get $B_addr))
    (local.set $R_addr (global.get $R_addr))

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
)