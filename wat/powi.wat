(module
  ;; https://github.com/jeremybarnes/cephes/blob/master/cmath/powi.c
  ;; ifdef UNK, DENORMAL

  (import "frexp" "frexp" (func $frexp (param f64) (result f64 i32)))

  (global $MAXLOG f64 (f64.const 7.09782712893383996732E2))
  (global $MINLOG f64 (f64.const -7.451332191019412076235E2))
  (global $LOG2E f64 (f64.const 1.4426950408889634073599))

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
)