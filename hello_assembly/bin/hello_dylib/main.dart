import 'package:ffi/ffi.dart';

import '../util/basic/clean_dir.dart';
import '../util/higher/assembly_to_object.dart';
import '../util/higher/binary_to_objdump.dart';
import '../util/higher/dylib_to_exports.dart';
import '../util/higher/object_to_dylib.dart';
import '../util/higher/write_assembly.dart';
import 'dart:ffi';

/// Chapter 09: https://github.com/below/HelloSilicon
Future<void> main() async {
  final root_dir = clean_dir(
    type: _Type,
    dir_name: "output",
  );
  final filename = root_dir + "hello_dylib";
  final assembly = r"""
// Assembler program to convert a string to
// all upper case.
//
// X1 - address of output string
// X0 - address of input string
// X4 - original output string for length calc.
// W5 - current character being processed

.global _mytoupper	     // Allow other files to call this routine
.p2align 2

_mytoupper:
	MOV	X4, X1

// The loop is until byte pointed to by X1 is non-zero
loop:	LDRB	W5, [X0], #1	// load character and increment pointer

// If W5 > 'z' then goto cont
	CMP	W5, #'z'	    // is letter > 'z'?
	B.GT	cont
	
// Else if W5 < 'a' then goto end if
	CMP	W5, #'a'
	B.LT	cont	// goto to end if
	
// If we got here then the letter is lower case, so convert it.
	SUB	W5, W5, #('a'-'A')
	
cont:	// end if
	STRB	W5, [X1], #1	// store character to output str
	CMP	W5, #0		// stop on hitting a null character
	B.NE	loop		// loop if character isn't null
	SUB	X0, X1, X4  // get the length by subtracting the pointers
	RET		// Return to caller
""";
  final dylib_output = object_to_dylib(
    input: assembly_to_object(
      input: string_to_file(
        path: filename + ".s",
        content: assembly,
      ),
      output: filename + ".o",
    ),
    output: filename + ".dylib",
  );
  final dylib = DynamicLibrary.open(
    dylib_output,
  );
  print(
    binary_to_objdump(
      input: dylib_output,
    ),
  );
  print(
    "Here are the exports provided by the dylib: \n" +
        dylib_to_exports(
          input: dylib_output,
        ),
  );
  print(
    _invoke(
      dylib: dylib,
      dart_string: "this is my string",
    ),
  );
  print(
    _invoke(
      dylib: dylib,
      dart_string: "this is my other string",
    ),
  );
}

String _invoke({
  required final DynamicLibrary dylib,
  required final String dart_string,
}) {
  final fn = dylib.lookupFunction<Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>(
    "mytoupper",
  );
  final native_string = dart_string.toNativeUtf8().cast<Uint8>();
  final target_string = malloc.allocate<Uint8>(
    dart_string.length * sizeOf<Uint8>(),
  );
  fn(
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

abstract class _Type {}
