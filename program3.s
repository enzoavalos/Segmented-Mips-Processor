.data 
num0: .word 1 # pos 0
num1: .word 2 # pos 4
num2: .word 4 # pos 8 
num3: .word 8 # pos 12 
num4: .word 16 # pos 16 
num5: .word 32 # pos 20
num6: .word 0 # pos 24
num7: .word 0 # pos 28
num8: .word 0 # pos 32
num9: .word 0 # pos 36
num10: .word 0 # pos 40
num11: .word 0 # pos 44
.text 
main:
  lw $t1, 0($zero) # load x1
  lw $t2, 4($zero) # load x2
  lw $t3, 8($zero) # load x4
  lw $t4, 12($zero) # load x8
  lw $t5, 16($zero) # load x10
  lw $t6, 20($zero) # load x20
  sw $t1, 24($zero) # store x1
  sw $t2, 28($zero) # store x2
  sw $t3, 32($zero) # store x4
  sw $t4, 36($zero) # store x8
  sw $t5, 40($zero) # store x10
  sw $t6, 44($zero) # store x20
  lw $t1, 24($zero) # load x1
  lw $t2, 28($zero) # load x2
  lw $t3, 32($zero) # load x4
  lw $t4, 36($zero) # load x8
  lw $t5, 40($zero) # load x10
  lw $t6, 44($zero) # load x20
  add $t7, $t1, $t2 # t7 = x3
  add $s0, $t3, $t4 # s0 = xC
  sub $s1, $t5, $t1 # s1 = xF
  sub $s2, $t6, $t2 # s2 = x1E
  and $s3, $t1, $t2 # s3 = 0
  and $s4, $t7, $t2 # s4 = x2
  or $s5, $t1, $t2 # s5 = x3
  or $s6, $s0, $t2 # s6 = xE
  slt $s7, $t1, $t2 # s7 = x1
  slt $t8, $s0, $t2 # s8 = 0
  nop
  beq $t1, $s7, salto1 #effective jump
  add $s0, $s0, $t1
  add $s1, $s1, $t1
  add $t1, $t1, $t1
salto1: beq $t1, $zero, salto2 #jump not taken
  add $s2, $s2, $t1
  add $s3, $s3, $t1
  add $t1, $t1, $t1
salto2: lui $t1, 1
  lui $t2, 2
  add $s1, $zero, $t3 #s1 = x4
  sub $t6, $t6, $s1 #RAW hazard in EX, t6 = x20 - x4 = x1C
  or $t8, $zero, $s1 #RAW hazard in MEM, t8 = x4
  
  
  
   
  
  
  

