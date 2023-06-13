import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../commander/commands.dart';
import '../commander/runner.dart';

void main() {
  final filename = clean_dir(type: _Type, dir_name: "output") + "hello_dylib";
  final assembly_path = filename + ".s";
  final object_path = filename + ".o";
  final dylib_path = filename + ".dylib";
  final program = Bindings._program().join("\n");
  run_Commander(
    commander: Commander_Commands_Impl(
      commands: [
        Command_WriteString_Impl(
          path: assembly_path,
          content: program,
        ),
        Command_as_Impl(
          input: assembly_path,
          output: object_path,
        ),
        Command_clang_Impl(
          input: object_path,
          output: dylib_path,
        )
      ],
    ),
  );
  final bindings = Bindings(
    dylib: DynamicLibrary.open(
      dylib_path,
    ),
  );
  print(
    run_and_take_output_commander(
      Command_objdump_Impl(
        input: dylib_path,
      ),
    ),
  );
  print(
    run_and_take_output_commander(
      Object_nm_Impl(
        input: dylib_path,
      ),
    ).splitMapJoin(
      "\n",
      onNonMatch: (final a) => " * " + a,
    ),
  );
  print(
    bindings.call_wrapped_example(
      dart_string: "lowercase: abc, uppercase: ABC",
    ),
  );
  bindings.svc4_stdout();
  bindings.svc1_quit();
}

// https://azeria-labs.com/arm-data-types-and-registers-part-2/
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
//       """
// // Example function to calculate the distance
// // between 4D two points in single precision
// // floating point using the NEON Processor
// // Inputs:
// //	X0 - pointer to the 8 FP numbers
// //		they are (x1, x2, x3, x4),
// //			 (y1, y2, y3, y4)
// // Outputs:
// //	W0 - the length (as single precision FP)
// .global _distance // Allow function to be called by others
// .align 4
//
// _distance:
// 	// load all 4 numbers at once
// 	LDP	Q2, Q3, [X0]
// 	FMUL V1.4S, V2.4S, V3.4S
// 	// // calc V1 = V2 - V3
// 	// FSUB	V1.4S, V2.4S, V3.4S
// 	// // calc V1 = V1 * V1 = (xi-yi)^2
// 	// FMUL	V1.4S, V1.4S, V1.4S
// 	// // calc S0 = S0 + S1 + S2 + S3
// 	// FADDP	V0.4S, V1.4S, V1.4S
// 	// FADDP	V0.4S, V0.4S, V0.4S
// 	// // // calc sqrt(S0)
// 	// // FSQRT	S4, S0
// 	// // move result to W0 to be returned
// 	// FMOV	W0, S4
// 	// FMOV	X0, R0
// 	RET
// """,
//       ..._macro_fn2(
//         name: neon_example,
//         body: [
//           "ldr q0, [x0]",
//           "movi v1.2d, #0x00ff0000000000ff",
//           "umin v0.8h, v0.8h, v1.8h",
//           "str q0, [x0]",
//         ],
//       ),
//       ..._macro_fn2(
//         name: popcount_name,
//         body: [
//           "add x0, x1, #10",
//         ],
//       ),
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

  static const String popcount_name = "popcount";
  static const String mytoupper_name = "mytoupper";
  static const String quit_name = "quit";
  static const String print_hello_world_name = "print_hello_world";
  static const String neon_example = "neon_example";

  final DynamicLibrary dylib;

  Bindings({
    required this.dylib,
  });

  String call_wrapped_example({
    required final String dart_string,
  }) {
    // final popcount =
    //     dylib.lookupFunction<Int Function(Int, Int), int Function(int, int)>(
    //   popcount_name,
    // );
    // // print(popcount(1000, 100));
    // final neon_example =
    //     dylib.lookupFunction<Void Function(Pointer), void Function(Pointer)>(
    //   'neon_example',
    // );
    // // final distance =
    // //     dylib.lookupFunction<Float Function(Pointer), double Function(Pointer)>(
    // //   'distance',
    // // );
    // final aa = malloc.allocate<Uint16>(sizeOf<Uint16>() * 8)
    //   ..elementAt(3).value = 999
    //   ..elementAt(2).value = 999
    //   ..elementAt(1).value = 999
    //   ..elementAt(0).value = 999;
    // neon_example(aa);
    // print(aa.elementAt(3).value);
    // print(aa.elementAt(2).value);
    // print(aa.elementAt(1).value);
    // print(aa.elementAt(0).value);
    // malloc.free(aa);
    // print(
    //   dylib
    //       .lookupFunction<Pointer Function(Pointer),
    //           Pointer Function(Pointer)>("distance")
    //       (malloc.allocate(sizeOf<Float>() * 8)).cast<Pointer>().value
    //       ,
    // );
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
