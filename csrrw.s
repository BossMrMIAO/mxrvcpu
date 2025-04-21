_start:
  li s10,0
  li s11,0

_test_1:
  lui  ra, 0x8
  csrrw sp, mtval, ra
  csrrw ra, mtval, sp
  csrrw t0, mtval, sp
  bne t0, sp, <_fail>

_pass:
  li s10,1
  li s11,1
  loop <>

_fail:
  li s10, 1
  li s11, 0
  loop <>

