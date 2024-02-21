(module

  (import "env" "mem" (memory 1))

  (func $fastexp_v128 (export "fastexp_v128") (param $idx i32) (param $SIZE i32)
    ;; https://stackoverflow.com/a/47025627 Schraudolph's algorithm
    ;; Max relative error 3.55959567e-2 on [-87.33654, 88.72283]
    (local $UNDER v128)
    (local $OVER v128)
    (local $INFS v128)
    (local $under_mask v128)
    (local $over_mask v128)
    (local $a v128)
    (local $b v128)
    (local $x v128)

    (local.set $UNDER (f32x4.splat (f32.const -87.33654)))
    (local.set $OVER (f32x4.splat (f32.const 88.72283)))
    (local.set $INFS (f32x4.splat (f32.const inf)))
    (local.set $a (f32x4.splat (f32.const 12102203)))
    (local.set $b (i32x4.splat (i32.sub 
      (i32.mul (i32.const 127) (i32.shl (i32.const 1) (i32.const 23))) 
      (i32.const 298765))))

    (loop $vec
      (local.get $idx) ;; leave idx on stack for saving back to memory
      (local.tee $x (v128.load align=4 (local.get $idx)))
      
      ;; Set masks to protect against under/overflow
      (local.set $under_mask (f32x4.ge (local.get $UNDER)))
      (local.set $over_mask (f32x4.le (local.get $x) (local.get $OVER)))

      ;; Calc exp and adjust output with under/over masks (->0, ->+inf, respectively)
      (local.tee $x (v128.bitselect
        (v128.and 
          (i32x4.add (local.get $b) (i32x4.trunc_sat_f32x4_s (f32x4.mul (local.get $a) (local.get $x)))) 
          (local.get $under_mask))
        (local.get $INFS)
        (local.get $over_mask)))
        
      (v128.store align=4) ;; idx, x on stack
      
      ;; Advance index or exit loop
      (i32.lt_s (local.tee $idx (i32.add (local.get $idx) (i32.const 16))) (local.get $SIZE))
      br_if $vec)
  )

  (func $fastexp (export "fastexp") (param $x f32) (result f32)
    ;; https://github.com/alan-carroll/wasm-fun/blob/875fb215d089fa4a7596a2f1f83b281137071917/wat/random.wat#L133
    ;; Added under/overflow protection
    (local $m i32)
    (local $i i32)

    ;; Under/overflow
    (if (f32.le (local.get $x) (f32.const -87.33654)) (then (f32.const 0) return))
    (if (f32.ge (local.get $x) (f32.const 88.72283)) (then (f32.const inf) return))

    (local.set $m (i32.and 
      (i32.shr_u 
        (local.tee $i (i32.add
          (i32.trunc_f32_s (f32.mul (local.get $x) (f32.const 12102203.0)))
          (i32.const 1065353216)))
        (i32.const 7))
      (i32.const 0xffff)))
    (local.tee $i (i32.add (local.get $i)
      (i32.sub (i32.shr_s  (i32.mul
      (i32.sub (i32.shr_s  (i32.mul
      (i32.add (i32.shr_s  (i32.mul 
        (i32.const 1277 )  (local.get $m)) (i32.const 14))
        (i32.const 14825)) (local.get $m)) (i32.const 14))
        (i32.const 79749)) (local.get $m)) (i32.const 11))
        (i32.const 626  ))))
    
    f32.reinterpret_i32
  )
)
