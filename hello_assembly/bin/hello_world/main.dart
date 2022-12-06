import '../util/basic/clean_dir.dart';
import '../util/basic/run.dart';
import '../util/higher/assembly_to_object.dart';
import '../util/higher/link_assembly.dart';
import '../util/higher/write_assembly.dart';

/// Chapter 01: https://github.com/below/HelloSilicon
Future<void> main() async {
  final filename = clean_dir(
        type: _Type,
        dir_name: "output",
      ) +
      "hello_arm64";
  run_command(
    command: link_assembly(
      input: assembly_to_object(
        input: string_to_file(
          content: r"""
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
""",
          path: filename + ".s",
        ),
        output: filename + ".o",
      ),
      output: filename + ".exe",
    ),
  );
}

abstract class _Type {}
