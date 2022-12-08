import '../commander/commands.dart';
import '../commander/runner.dart';

void main() {
  final filename = clean_dir(type: _Type, dir_name: "output") + "hello_arm64";
  final assembly_path = filename + ".s";
  final object_path = filename + ".o";
  final binary_path = filename + ".exe";
  const assembly = r"""
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
""";
  run_Commander(
    commander: Commander_Commands_Impl(
      commands: [
        Command_WriteString_Impl(
          path: assembly_path,
          content: assembly,
        ),
        Command_as_Impl(
          input: assembly_path,
          output: object_path,
        ),
        Command_ld_Impl(
          input: object_path,
          output: binary_path,
        ),
        Command_binary_Impl(
          c: binary_path,
        ),
      ],
    ),
  );
}

abstract class _Type {}
