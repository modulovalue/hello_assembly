import 'package:ffi/ffi.dart';

import '../util/basic/clean_dir.dart';
import '../util/higher/assembly_to_object.dart';
import '../util/higher/object_to_dylib.dart';
import '../util/higher/write_assembly.dart';
import 'dart:ffi';

/// Chapter 09: https://github.com/below/HelloSilicon
void main() {
  final root_dir = clean_dir(
    type: _Type,
    dir_name: "output",
  );
  final filename = root_dir + "hello_dylib";
  final dylib_path = object_to_dylib(
    input: assembly_to_object(
      input: string_to_file(
        path: filename + ".s",
        content: Bindings._program().join("\n"),
      ),
      output: filename + ".o",
    ),
    output: filename + ".dylib",
  );
  final bindings = Bindings(
    dylib: DynamicLibrary.open(
      dylib_path,
    ),
  );
  print(
    bindings.call_wrapped_example(
      dart_string: "this is my string! 123 abc ABC",
    ),
  );
  bindings.svc4_stdout();
  bindings.svc1_quit();
}

class Bindings {
  static List<String> _program() {
    return [
      // Assembly program to convert a string to all upper case.
      // X1 - address of output string
      // X0 - address of input string
      // X4 - original output string for length calc.
      // W5 - current character being processed
      ..._macro_fn2(
        name: mytoupper_name,
        body: [
          "  MOV	  X4, X1",
          "loop:	",
          // Load character and increment pointer.
          "  LDRB  W5, [X0], #1",
          // If W5 > 'z' then goto cont.",
          "	 CMP W5, #'z'",
          "	 B.GT	cont",
          // Else if W5 < 'a' then goto end if.
          "	 CMP W5, #'a'",
          // Goto to end if.
          "	 B.LT	cont",
          // If we got here then the letter is lower case, so convert it.
          "	 SUB W5, W5, #('a'-'A')",
          "cont:",
          // Store character to output str.
          "	 STRB	W5, [X1], #1",
          // Stop on hitting a null character.
          "	 CMP W5, #0",
          // Loop if character isn't null.
          "	 B.NE	loop",
          // Get the length by subtracting the pointers.
          "	 SUB X0, X1, X4",
        ],
      ),
      // TODO service command code 0?
      ..._macro_system_1_terminate(
        label: quit_name,
      ),
      // TODO service command code 2?
      // TODO service command code 3?
      ..._macro_system_4_stdout(
        label: print_hello_world_name,
      ),
      // TODO service command code N?
    ];
  }

  static const String mytoupper_name = "mytoupper";
  static const String quit_name = "quit";
  static const String print_hello_world_name = "print_hello_world";

  final DynamicLibrary dylib;

  Bindings({
    required final this.dylib,
  });

  String call_wrapped_example({
    required final String dart_string,
  }) {
    final native_string = dart_string.toNativeUtf8().cast<Uint8>();
    final target_string = malloc.allocate<Uint8>(
      dart_string.length * sizeOf<Uint8>(),
    );
    this.to_upper(
      native_string,
      target_string,
    );
    final output_string = target_string.cast<Utf8>().toDartString(
          length: dart_string.length,
        );
    malloc.free(native_string);
    malloc.free(target_string);
    return output_string;
  }

  late final to_upper = dylib.lookupFunction<
      Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>(
    mytoupper_name,
  );
  late final svc4_stdout =
      dylib.lookupFunction<Void Function(), void Function()>(
    print_hello_world_name,
  );
  late final svc1_quit = dylib.lookupFunction<Void Function(), void Function()>(
    quit_name,
  );
}

abstract class _Type {}

// region macros
List<String> _macro_system_1_terminate({
  required final String label,
}) {
  return _macro_fn2(
    name: label,
    body: [
      // Set the return code.
      "MOV X0, #42",
      ..._macro_invoke_service_command(
        code: 1,
      ),
    ],
  );
}

List<String> _macro_system_4_stdout({
  required final String label,
}) {
  return [
    // TODO take a string and remove the helloworld section.
    'helloworld: .ascii "Hello World!\\n"',
    ..._macro_fn2(
      name: label,
      body: [
        // 1 = StdOut.
        "MOV X0, #1",
        // String to print.
        "ADR X1, helloworld",
        // Length of our string.
        "MOV X2, #13",
        ..._macro_invoke_service_command(
          code: 4,
        ),
      ],
    ),
  ];
}

List<String> _macro_fn2({
  required final String name,
  required final List<String> body,
}) {
  return [
    ".p2align 2",
    ".global _" + name,
    "_" + name + ":",
    ...body,
    "RET",
  ];
}

List<String> _macro_invoke_service_command({
  required final int code,
}) {
  return [
    // Set the service command code.
    "MOV X16, #" + code.toString(),
    // Call linux to output the string.
    "SVC 0",
  ];
}
// endregion
