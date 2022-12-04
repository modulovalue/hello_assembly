import '../util/basic/clean_dir.dart';
import '../util/basic/run.dart';
import '../util/higher/assembly_to_object.dart';
import '../util/higher/binary_to_objdump.dart';
import '../util/higher/link_assembly.dart';
import '../util/higher/write_assembly.dart';

/// Chapter 01: https://github.com/below/HelloSilicon
Future<void> main() async {
  final root_dir = clean_dir(
    type: _Type,
    dir_name: "output",
  );
  final filename = root_dir + "hello_arm64";
  final assembly = r"""
// Assembler program to print "Hello World!"
// to stdout.
// X0-X2 - parameters to linux function services
// X16 - linux function number
.global _start             // Provide program starting address to linker
.align 2
// Setup the parameters to print hello world
// and then call Linux to do it.
_start: 
  mov X0, #1          // 1 = StdOut
  adr X1, helloworld  // string to print
  mov X2, #13         // length of our string
  mov X16, #4         // MacOS write system call
  svc 0               // Call linux to output the string
// Setup the parameters to exit the program
// and then call Linux to do it.
  mov     X0, #0      // Use 0 return code
  mov     X16, #1     // Service command code 1 terminates this program
  svc     0           // Call MacOS to terminate the program
helloworld:      
  .ascii  "Hello World!\n"
""";
  final binary = link_assembly(
    input: assembly_to_object(
      input: string_to_file(
        path: filename + ".s",
        content: assembly,
      ),
      output: filename + ".o",
    ),
    output: filename + ".exe",
  );
  run_command(
    command: binary,
  );
  print(
    binary_to_objdump(
      input: binary,
    ),
  );
}

abstract class _Type {}
