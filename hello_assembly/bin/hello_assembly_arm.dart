import 'dart:io';

import 'util/clean_dir.dart';
import 'util/run.dart';

/// Chapter 01: https://github.com/below/HelloSilicon
Future<void> main() async {
  const assembly = r"""
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
  // region housekeeping
  final root_dir_path = clean_dir(
    type: _Type,
    dir_name: "output_arm64",
  );
  // endregion
  // region names
  final filename = root_dir_path + "hello_arm64";
  final asm_filename = filename + ".s";
  final asm_o_filename = filename + ".o";
  final binary_filename = filename + ".exe";
  // endregion
  // region write assembly
  File(
    asm_filename,
  ).writeAsString(
    assembly,
  );
  // endregion
  // region compile assembly
  run(
    "as",
    [
      "-arch",
      "arm64",
      asm_filename,
      "-o",
      asm_o_filename,
    ],
  );
  // endregion
  // region link
  run(
    "ld",
    [
      "-o",
      binary_filename,
      asm_o_filename,
      "-lSystem",
      "-syslibroot",
      run_to_get(
        "xcrun",
        ["-sdk", "macosx", "--show-sdk-path"],
      ),
      "-e",
      "_start",
      "-arch",
      "arm64",
    ],
  );
  // endregion
  // region run
  run(
    binary_filename,
    [],
  );
  // endregion
}

abstract class _Type {}
