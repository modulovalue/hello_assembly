.p2align 2
.global _mytoupper
_mytoupper:
  MOV	  X4, X1
loop:	
  LDRB  W5, [X0], #1
	 CMP W5, #'z'
	 B.GT	cont
	 CMP W5, #'a'
	 B.LT	cont
	 SUB W5, W5, #('a'-'A')
cont:
	 STRB	W5, [X1], #1
	 CMP W5, #0
	 B.NE	loop
	 SUB X0, X1, X4
RET
// Example function to calculate the distance
// between 4D two points in single precision
// floating point using the NEON Processor
// Inputs:
//	X0 - pointer to the 8 FP numbers
//		they are (x1, x2, x3, x4),
//			 (y1, y2, y3, y4)
// Outputs:
//	W0 - the length (as single precision FP)
.global _distance // Allow function to be called by others
.align 4

_distance:	
	// load all 4 numbers at once
	LDP	Q2, Q3, [X0]	
	FMUL V1.4S, V2.4S, V3.4S
	// // calc V1 = V2 - V3
	// FSUB	V1.4S, V2.4S, V3.4S
	// // calc V1 = V1 * V1 = (xi-yi)^2
	// FMUL	V1.4S, V1.4S, V1.4S
	// // calc S0 = S0 + S1 + S2 + S3
	// FADDP	V0.4S, V1.4S, V1.4S
	// FADDP	V0.4S, V0.4S, V0.4S
	// // // calc sqrt(S0)
	// // FSQRT	S4, S0 
	// // move result to W0 to be returned
	// FMOV	W0, S4
	// FMOV	X0, R0
	RET

.p2align 2
.global _neon_example
_neon_example:
ldr q0, [x0]
movi v1.2d, #0x00ff0000000000ff
umin v0.8h, v0.8h, v1.8h
str q0, [x0]
RET
.p2align 2
.global _popcount
_popcount:
add x0, x1, #10
RET
.p2align 2
.global _quit
_quit:
MOV X0, #42
MOV X16, #1
SVC 0
RET
helloworld: .ascii "Hello World!\n"
.p2align 2
.global _print_hello_world
_print_hello_world:
MOV X0, #1
ADR X1, helloworld
MOV X2, #13
MOV X16, #4
SVC 0
RET