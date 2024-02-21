(module
  ;; https://github.com/jeremybarnes/cephes/blob/master/cprob/polevl.c

  (memory (export "coef") 1)

  (func $polevl_f64 (export "polevl_f64") (param $x f64) (param $N i32) (result f64)
    (local $p i32)
    (local $ans f64)
    (local.set $p (i32.const 0))
    (local.set $ans (f64.load (local.get $p)))
    (loop $coef
      (local.set $p (i32.add (local.get $p) (i32.const 8)))
      (local.set $ans 
        (f64.add
          (f64.mul (local.get $ans) (local.get $x))
          (f64.load (local.get $p))))
      (local.tee $N (i32.sub (local.get $N) (i32.const 1)))
      br_if $coef)

    (local.get $ans))

  (func $plevl_f64 (export "plevl_f64") (param $x f64) (param $N i32) (result f64)
    (local $p i32)
    (local $ans f64)
    (local.set $p (i32.const 0))
    (local.set $ans (f64.add (local.get $x) (f64.load (local.get $p))))
    (local.set $N (i32.sub (local.get $N) (i32.const 1)))
    (loop $coef
      (local.set $p (i32.add (local.get $p) (i32.const 8)))
      (local.set $ans 
        (f64.add
          (f64.mul (local.get $ans) (local.get $x))
          (f64.load (local.get $p))))
      (local.tee $N (i32.sub (local.get $N) (i32.const 1)))
      br_if $coef)

    (local.get $ans))

  (func $polevl_f32 (export "polevl_f32") (param $x f32) (param $N i32) (result f32)
    (local $p i32)
    (local $ans f32)
    (local.set $p (i32.const 0))
    (local.set $ans (f32.load (local.get $p)))
    (loop $coef
      (local.set $p (i32.add (local.get $p) (i32.const 4)))
      (local.set $ans 
        (f32.add
          (f32.mul (local.get $ans) (local.get $x))
          (f32.load (local.get $p))))
      (local.tee $N (i32.sub (local.get $N) (i32.const 1)))
      br_if $coef)

    (local.get $ans))

  (func $plevl_f32 (export "plevl_f32") (param $x f32) (param $N i32) (result f32)
    (local $p i32)
    (local $ans f32)
    (local.set $p (i32.const 0))
    (local.set $ans (f32.add (local.get $x) (f32.load (local.get $p))))
    (local.set $N (i32.sub (local.get $N) (i32.const 1)))
    (loop $coef
      (local.set $p (i32.add (local.get $p) (i32.const 4)))
      (local.set $ans 
        (f32.add
          (f32.mul (local.get $ans) (local.get $x))
          (f32.load (local.get $p))))
      (local.tee $N (i32.sub (local.get $N) (i32.const 1)))
      br_if $coef)

    (local.get $ans))

)