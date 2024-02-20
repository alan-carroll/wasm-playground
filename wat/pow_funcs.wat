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
  
  ;; pow
  (global $SQRTH f64 (f64.const 0.70710678118654752440))
  (global $MEXP f64 (f64.const 16383.0))
  (global $MNEXP f64 (f64.const -17183.0)) ;; denormal
  (global $LOG2EA f64 (f64.const 0.44269504088896340736)) ;; log2(e) - 1
  
  ;; frexp / ldexp
  (global $two54 f64 (f64.const 1.80143985094819840000e+16))
  (global $twom54 f64 (f64.const 5.55111512312578270212e-17))
  
  (global $MAXNUM f64 (f64.const 1.79769313486231570815E308))
  (global $MAXLOG f64 (f64.const 7.09782712893383996732E2))
  (global $MINLOG f64 (f64.const -7.451332191019412076235E2))
  (global $LOG2E f64 (f64.const 1.4426950408889634073599))

  (start $init)

  (func $_store (param $addr i32) (param $off i32) (param $val f64)
    (f64.store (i32.add 
      (local.get $addr) 
      (i32.mul (local.get $off) (i32.const 8)))
      (local.get $val))
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
  
  (func $powi (export "powi") (param $x f64) (param $nn i32) (result f64)
    (local $n i32)
    (local $e i32)
    (local $sign i32)
    (local $asign i32)
    (local $lx i32)
    (local $w f64)
    (local $y f64)
    (local $s f64)

    (block $ret

      ;; #L64-81 skipping tests as already done by `pow`

      ;; #L83 nn == -1
      (if (i32.eq (local.get $nn) (i32.const -1)) (then (f64.div (f64.const 1) (local.get $x)) (br $ret)))
      ;; #L95 nn < 0
      (if (i32.lt_s (local.get $nn) (i32.const 0)) 
        (then (local.set $sign (i32.const -1)) (local.set $n (i32.sub (i32.const 0) (local.get $nn))))
        (else (local.set $sign (i32.const 1) (local.set $n (local.get $nn)))))

      ;; Combine #L86 x < 0.0 and #L107 (n & 1) -> odd power, determines $asign
      (if (f64.lt (local.get $x) (f64.const 0)) (then 
        (local.set $x (f64.neg (local.get $x)))
        (if (i32.and (local.get $n) (i32.const 1))
          (then (local.set $asign (i32.const -1))))))
      
      ;; #L112 Calc approx log of answer
      (call $frexp (local.get $x))
      local.set $lx
      local.set $s
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
        (global.get $LOG2E) f64.mul
        (local.tee $s)
      else (local.tee $s (f64.mul (f64.convert_i32_s (local.get $e)) (global.get $LOG2E))) end ;; #L122, s on the stack
      (global.get $MAXLOG) f64.gt if (local.set $y (f64.const inf)) (br $ret) end ;; #L125

      ;; #L132 handle denormal
      (if (f64.lt (local.get $s) (global.get $MINLOG)) (then (local.set $y (f64.const 0)) (br $ret)))
      ;; #L143 more denormal
      (f64.lt (local.get $s) (f64.add (f64.neg (global.get $MAXLOG)) (f64.const 2))) ;; (s < (-MAXLOG+2.0))
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
        (loop $while_n
          (local.set $w (f64.mul (local.get $w) (local.get $w)))
          (if (i32.and (local.get $n) (i32.const 1)) (then
            (local.set $y (f64.mul (local.get $y) (local.get $w)))))
          (local.tee $n (i32.shr_s (local.get $n) (i32.const 1)))
          br_if $while_n)
      end

      (if (i32.lt_s (local.get $sign) (i32.const 0)) (then
        (local.set $y (f64.div (f64.const 1) (local.get $y)))))
    ) ;; end $ret

    ;; #L175 - done:
    (local.get $asign) ;; odd power of negative number
    if (result f64)
      (f64.eq (local.get $y) (f64.const 0))
      if (result f64) (f64.const -0) else (f64.neg (local.get $y)) end
    else (local.get $y) end
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

    (block $ret (result f64)
      (if (f64.eq (local.get $y) (f64.const 0)) (then (f64.const 1) (br $ret))) ;; #L374 y == 0.0
      (if (i32.eqz (f64.eq (local.get $x) (local.get $x))) (then (local.get $x) (br $ret))) ;; isnan(x)
      (if (i32.eqz (f64.eq (local.get $y) (local.get $y))) (then (local.get $y) (br $ret))) ;; isnan(y)
      (if (f64.eq (local.get $y) (f64.const 1)) (then (local.get $x) (br $ret))) ;; y == 1.0

      ;; isfinite(y) - checks +/- inf and nan
      local.get $y
      i64.reinterpret_f64
      i64.const 32
      i64.shr_s
      i32.wrap_i64
      i32.const 0x7ff00000
      i32.and
      i32.const 0x7ff00000
      i32.ne
      i32.eqz
      if ;; y not finite #L387
        (f64.eq (local.get $x) (f64.const 1))
        if (f64.const nan) (br $ret) ;; x == 1.0
        else
          (f64.eq (local.get $x) (f64.const -1))
          if (f64.const nan) (br $ret) ;; or x == -1.0
          end
        end
      end

      (if (f64.eq (local.get $x) (f64.const 1)) (then (f64.const 1) (br $ret))) ;; #L398 x == 1.0
      (if (f64.ge (local.get $y) (global.get $MAXNUM)) (then ;; y >= MAXNUM #L401
        (if (f64.gt (local.get $x) (f64.const 1)) (then (f64.const inf) (br $ret))) ;; x > 1.0
        (if (f64.gt (local.get $x) (f64.const 0)) (then  ;; 0.0 > x && x < 1.0
          (if (f64.lt (local.get $x) (f64.const 1)) (then (f64.const 0) (br $ret)))))
        (if (f64.lt (local.get $x) (f64.const -1)) (then (f64.const inf) (br $ret))) ;; x < -1.0
        (if (f64.gt (local.get $x (f64.const -1))) (then ;; x > -1.0 && x < 0.0
          (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const 0) (br $ret)))))))
      (if (f64.le (local.get $y) (f64.neg (global.get $MAXNUM))) (then ;; y <= -MAXNUM #L423
        (if (f64.gt (local.get $x) (f64.const 1)) (then (f64.const 0) (br $ret))) ;;  x > 1.0
        (if (f64.gt (local.get $x) (f64.const 0)) (then  ;; x > 0.0 && x < 1.0
          (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const inf) (br $ret)))))
        (if (f64.lt (local.get $x) (f64.const -1)) (then (f64.const 0) (br $ret))) ;; x < -1.0
        (if (f64.gt (local.get $x) (f64.const -1)) (then ;; x > -1.0 && x < 0.0
          (if (f64.lt (local.get $x) (f64.const 0)) (then (f64.const inf) (br $ret))))))) 
      (if (f64.ge (local.get $x) (global.get $MAXNUM)) (then ;; x >= MAXNUM #L444
        (if (f64.gt (local.get $y) (f64.const 0)) (then (f64.const inf) (br $ret)) ;; y > 0.0
          (else (f64.const 0) (br $ret)))))

      ;; #L456 - is y an int
      (local.tee $w (f64.floor (local.get $y)))
      local.get $y
      f64.eq
      local.tee $iyflg
      if ;; #L461 - is y odd int
        (local.tee $ya (f64.floor (f64.mul (f64.const 0.5) (f64.abs (local.get $y)))))
        (local.tee $yb (f64.mul (f64.const 0.5) (f64.abs (local.get $w))))
        f64.ne
        local.set $yoddint
      end

      (if (f64.le (local.get $x) (f64.neg (global.get $MAXNUM))) (then ;; x <= -MAXNUM #L472
        (if (f64.gt (local.get $y) (f64.const 0)) (then ;; y > 0.0
          (if (local.get $yoddint) (then (f64.const -inf) (br $ret)) (else (f64.const inf) (br $ret))))) ;; yoddint
        (if (f64.lt (local.get $y) (f64.const 0)) (then ;; y < 0.0
          (if (local.get $yoddint) (then (f64.const -0) (br $ret)) (else (f64.const 0) (br $ret)))))))  ;; yoddint
      
      ;; #L496 - is x<0 raised to int power
      (if (f64.le (local.get $x) (f64.const 0)) (then ;; x <= 0.0
        (if (f64.eq (local.get $x) (f64.const 0)) (then ;; x == 0.0
          (if (f64.lt (local.get $y) (f64.const 0)) (then ;; y < 0.0
            ;; signbit(x)
            local.get $x
            i64.reinterpret_f64
            i64.const 32
            i64.shr_s
            i32.wrap_i64
            i32.const 0
            i32.lt_s
            local.get $yoddint
            i32.and ;; signbit(x) && yoddint
            if (f64.const -inf) br $ret else (f64.const inf) br $ret end))
          (if (f64.gt (local.get $y) (f64.const 0)) (then ;; y > 0.0
            ;; signbit(x)
            local.get $x
            i64.reinterpret_f64
            i64.const 32
            i64.shr_s
            i32.wrap_i64
            i32.const 0
            i32.lt_s
            local.get $yoddint
            i32.and ;; signbit(x) && yoddint
            if (f64.const -0) br $ret else (f64.const 0) br $ret end))
          (f64.const 1) (br $ret)) ;; implicit y==0 #L521
          (else ;; implicit x < 0.0 #L523
            (if (local.get $iyflg) (then (f64.const nan) (br $ret))) ;; noninteger power of negative number
            (local.set $nflg (i32.const 1))))))
      
      ;; #L540 - int power of an int
      local.get $iyflg
      if
        (f64.eq (local.tee $w (f64.floor (local.get $x))) (local.get $x))
        if ;; (w == x)
          (f64.lt (f64.abs (local.get $y)) (f64.const 32768.0))
          if ;; && (fabs(y) < 32768.0)
            (call $powi (local.get $x) (i32.trunc_f64_s (local.get $y))) 
            (br $ret)
          end
        end
      end

      (local.get $nflg) if (local.set $x (f64.abs (local.get $x))) end ;; #L551

      ;; #L555 - series expansion for results close to 1
      (local.tee $w (f64.sub (local.get $x) (f64.const 1)))
      f64.abs (local.set $aw)
      (local.set $ay (f64.abs (local.get $y)))
      (local.tee $wy (f64.mul (local.get $w) (local.get $y)))
      f64.abs (local.set $ya)
      ;; #L560 ((aw <= 1.0e-3 && ay <= 1.0) || (ya <= 1.0e-3 && ay >= 1.0))
      (block $z_or (result i32)
        (f64.le (local.get $aw) (f64.const 1.0e-3))
        if ;; (aw <= 1.0e-3 && ay <= 1.0)
          (f64.le (local.get $ay) (f64.const 1.0))
          if (i32.const 1) (br $z_or) end
        end
        (f64.le (local.get $ya) (f64.const 1.0e-3))
        if ;; (ya <= 1.0e-3 && ay >= 1.0)
          (f64.ge (local.get $ay) (f64.const 1))
          if (i32.const 1) (br $z_or) end
        end
        (i32.const 0)) ;; false
      if ;; if z_or block true 
      ;; (((((w*(y-5.)/720. + 1./120.)*w*(y-4.) + 1./24.)*w*(y-3.) + 1./6.)*w*(y-2.) + 0.5)*w*(y-1.) )*wy + wy + 1.
        (;
          (
            (
              (
                (
                  (w * (y-5.)/720. + 1./120.
                  ) * w * (y-4.) + 1./24.
                ) * w * (y-3.) + 1./6.
              ) * w * (y-2.) + 0.5
            ) * w * (y-1.)
          ) * wy + wy + 1.
        ;)
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
              (then (f64.const -0) (br $ret))
              (else (f64.neg (local.get $z)) (br $ret))))
            (else (local.get $z) (br $ret))))
          (else (local.get $z) (br $ret)))
      end ;; end z_or block true

      ;; #L591 'separate significand from exponent'
      (call $frexp (local.get $x))
      local.set $e
      local.set $x

      ;; #L600 'find significand of x in antilog table A[]'
      (local.set $i (i32.const 1))
      (if (f64.le (local.get $x) (f64.load (i32.add 
        (global.get $A_addr) 
        (i32.mul (i32.const 8) (i32.const 9)))))
        (then (local.set $i (i32.const 9))))
      (if (f64.le (local.get $x) (f64.load (i32.add 
        (global.get $A_addr) 
        (i32.add (i32.mul (i32.const 8) (local.get $i))
          (i32.mul (i32.const 8) (i32.const 4))))))
        (then (local.set $i (i32.add (local.get $i) (i32.const 4)))))
      (if (f64.le (local.get $x) (f64.load (i32.add 
        (global.get $A_addr) 
        (i32.add (i32.mul (i32.const 8) (local.get $i)) 
          (i32.mul (i32.const 8) (i32.const 2))))))
        (then (local.set $i (i32.add (local.get $i) (i32.const 2)))))
      (if (f64.ge (local.get $x) (f64.load (i32.add 
        (global.get $A_addr) 
        (i32.mul (i32.const 8) (i32.const 1)))))
        (then (local.set $i (i32.const -1))))
      (local.set $i (i32.add (local.get $i) (i32.const 1)))

      ;; #L620
      (local.get $x)
      (f64.load (i32.add (global.get $A_addr) (i32.mul (i32.const 8) (local.get $i))))
      f64.sub
      (f64.load (i32.add (global.get $B_addr) (i32.div_s (i32.mul (i32.const 8) (local.get $i)) (i32.const 2))))
      f64.sub
      (f64.load (i32.add (global.get $A_addr) (i32.mul (i32.const 8) (local.get $i))))
      f64.div
      (local.tee $x)
      (local.get $x)
      f64.mul
      (local.tee $z) ;; #L629
      ;; polevl( x, P, 3 )
      (local.set $_N (i32.const 3))
      (local.set $_polans (f64.load (local.tee $_ptr (global.get $P_addr))))
      (loop $P_coef_loop
        (f64.mul (local.get $_polans) (local.get $x))
        (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
        f64.load
        f64.add
        (local.set $_polans)
        (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
        br_if $P_coef_loop)
      (local.get $_polans)
      f64.mul ;; z * polevl
      ;; plevl( x, Q, 4)
      (local.set $_N (i32.const 3)) ;; plevl uses N-1
      (local.set $_polans (f64.add (local.get $x) (f64.load (local.tee $_ptr (global.get $Q_addr)))))
      (loop $Q_coef_loop
        (f64.mul (local.get $_polans) (local.get $x))
        (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
        f64.load
        f64.add
        (local.set $_polans)
        (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
        br_if $Q_coef_loop)
      (local.get $_polans)
      f64.div ;; z * polevl / plevl
      (local.get $x)
      f64.mul
      (call $ldexp (local.get $z) (i32.const -1))
      f64.sub
      (local.tee $w) ;; #L630-631
      (global.get $LOG2EA)
      f64.mul
      (local.get $w)
      f64.add
      (global.get $LOG2EA)
      (local.get $x)
      f64.mul
      f64.add
      (local.get $x)
      f64.add
      (local.set $z) ;; #L643

      ;; #L646-699
      (local.tee $w (f64.add 
        (f64.convert_i32_s (local.get $e))
        (call $ldexp (f64.neg (f64.convert_i32_s (local.get $i))) (i32.const -4))))
      (local.tee $yb (f64.sub (local.get $y) (local.tee $ya (call $reduc (local.get $y)))))
      f64.mul ;; #L660 w * yb
      (f64.mul (local.get $z) (local.get $y))
      f64.add
      (local.tee $W)
      (local.tee $Wa (call $reduc (local.get $W)))
      f64.sub  ;; #L662 F - Fa
      (local.tee $Wb) ;; Fb on the stack
      (local.tee $W (f64.add (local.get $Wa) (f64.mul (local.get $w) (local.get $ya))))
      (local.tee $Wa (call $reduc (local.get $W)))
      f64.sub ;; #L666 G - Ga
      (local.tee $u) ;; Gb on the stack
      f64.add ;; Fb + Gb, stack clear
      (local.tee $W) ;; #L668, H
      (call $reduc)
      (local.tee $Wb)
      (local.get $Wa)
      f64.add
      (i32.const 4)
      (call $ldexp)
      (local.tee $w) ;; #L670
      (global.get $MEXP)
      f64.gt
      if ;; $L673
        (if (local.get $nflg) 
          (then (if (local.get $yoddint) 
            (then (f64.const -inf) (br $ret)) 
            (else (f64.const inf) (br $ret))))
          (else (f64.const inf) (br $ret)))
      end
      (f64.lt (local.get $w) (f64.sub (global.get $MNEXP) (f64.const 1)))
      if ;; #L689
        (if (local.get $nflg) 
          (then (if (local.get $yoddint) 
            (then (f64.const -0) (br $ret))
            (else (f64.const 0) (br $ret))))
          (else (f64.const 0) (br $ret)))
      end

      (local.set $e (i32.trunc_f64_s (local.get $w)))
      (local.tee $Wb (f64.sub (local.get $W) (local.get $Wb))) ;; #L702
      (f64.const 0)
      f64.gt
      if 
        (local.set $e (i32.add (local.get $e) (i32.const 1)))
        (local.set $Wb (f64.sub (local.get $Wb) (f64.const 0.0625)))
      end

      ;; #L715 polevl( Hb, R, 6 )
      (local.get $Wb)
      (local.set $_N (i32.const 6))
      (local.set $_polans (f64.load (local.tee $_ptr (global.get $R_addr))))
      (loop $R_coef_loop
        (f64.mul (local.get $_polans) (local.get $Wb))
        (local.tee $_ptr (i32.add (local.get $_ptr) (i32.const 8)))
        f64.load
        f64.add
        (local.set $_polans)
        (local.tee $_N (i32.sub (local.get $_N) (i32.const 1)))
        br_if $R_coef_loop)
      (local.get $_polans)
      f64.mul ;; Hb * polevl
      (local.set $z)

      (local.tee $i (select (i32.const 0) (i32.const 1) (i32.lt_s (local.get $e) (i32.const 0)))) ;; #L720
      (i32.div_s (local.get $e) (i32.const 16))
      i32.add
      (local.tee $i) ;; #L724 i = e/16 + i;
      (i32.const 16)
      i32.mul
      (local.get $e)
      i32.sub
      (local.tee $e)
      (i32.const 8)
      i32.mul ;; douba(e)
      (global.get $A_addr)
      i32.add
      f64.load
      (local.tee $w)
      (local.get $z)
      f64.mul
      (local.get $w)
      f64.add
      (local.tee $z) ;; #L727
      (local.get $i)
      (call $ldexp)
      (local.set $z) ;; z on stack, returns for $ret if nflg/yoddint false, #L730-743
      (local.get $nflg)
      if
        local.get $yoddint
        if
          (f64.const 0)
          (local.get $z)
          f64.eq ;; z off stack
          if (f64.const -0) (br $ret) else (f64.neg (local.get $z)) (br $ret) end
        end
      end
      (local.get $z)
    ) ;; end $ret
  )
)