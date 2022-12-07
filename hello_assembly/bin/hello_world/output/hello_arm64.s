// Assembler program to print "Hello World!" to stdout.
// X0-X2 - parameters to linux function services.
// X16 - linux function number.
.global _start
.align 2
_start: 
  mov X0, #1          // 1 = StdOut.
  adr X1, helloworld  // String to print.
  mov X2, #13         // Length of our string.
  mov X16, #4         // MacOS write system call.
  svc 0               // Call linux to output the string.
  RET
helloworld:      
  .ascii  "Hello World!\n"
  
  
.global count_bits

count_bits:
  mov d0[0], r0
  vcnt.8  d0, d0
  mov r0, d0[0]
  add r0, r0, r0, lsr #16
  add r0, r0, r0, lsr #8
  and r0, r0, #31
  RET
