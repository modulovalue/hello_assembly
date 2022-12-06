import 'package:ffi/ffi.dart';

import '../util/basic/clean_dir.dart';
import '../util/higher/assembly_to_object.dart';
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
  final assembly = """
// Assembly program to convert a string to
// all upper case.
//
// X1 - address of output string
// X0 - address of input string
// X4 - original output string for length calc.
// W5 - current character being processed
.p2align 2
.global _mytoupper	       // Allow other files to call this routine.
_mytoupper:
	MOV	  X4, X1
loop:	
  LDRB  W5, [X0], #1	     // Load character and increment pointer.
	CMP	  W5, #'z'	         // If W5 > 'z' then goto cont.
	B.GT	cont
	CMP	  W5, #'a'           // Else if W5 < 'a' then goto end if.
	B.LT	cont            	 // Goto to end if.
	SUB	  W5, W5, #('a'-'A') // If we got here then the letter is lower case, so convert it.
cont:
	STRB	W5, [X1], #1	     // Store character to output str.
	CMP	  W5, #0		         // Stop on hitting a null character.
	B.NE	loop               // Loop if character isn't null.
	SUB	  X0, X1, X4         // Get the length by subtracting the pointers.
	RET		                   // Return to caller.
	
// TODO service command code 0?

${macro_system_1_terminate(label: "_quit")}

// TODO service command code 2?

// TODO service command code 3?

${macro_system_4_stdout(label: "_print_hello_world")}

// TODO service command code N?
""";
  final dylib_path = object_to_dylib(
    input: assembly_to_object(
      input: string_to_file(
        path: filename + ".s",
        content: assembly,
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
    _invoke(
      dylib: bindings,
      dart_string: "this is my string",
    ),
  );
  print(
    _invoke(
      dylib: bindings,
      dart_string: "this is my other string",
    ),
  );
  bindings.print_hello_world();
  bindings.quit();
}

class Bindings {
  final DynamicLibrary dylib;

  Bindings({
    required final this.dylib,
  });

  late final mytoupper = dylib.lookupFunction<
      Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>(
    "mytoupper",
  );
  late final print_hello_world =
      dylib.lookupFunction<Void Function(), void Function()>(
    "print_hello_world",
  );
  late final quit = dylib.lookupFunction<Void Function(), void Function()>(
    "quit",
  );
}

String _invoke({
  required final Bindings dylib,
  required final String dart_string,
}) {
  final native_string = dart_string.toNativeUtf8().cast<Uint8>();
  final target_string = malloc.allocate<Uint8>(
    dart_string.length * sizeOf<Uint8>(),
  );
  dylib.mytoupper(
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

// region macros
String macro_system_1_terminate({
  required final String label,
}) {
  return """
// Service command code 1.
.p2align 2
.global _quit
${label}: 
  mov     X0, #42          // Use 0 return code.
  mov     X16, #1          // Service command code 1 terminates this program.
  svc     0                // Call MacOS to terminate the program.
""";
}

String macro_system_4_stdout({
  required final String label,
}) {
  // TODO take a string and remove the helloworld section.
  return """
// Service command code 4.
.p2align 2
.global _print_hello_world
_print_hello_world: 
  mov     X0, #1           // 1 = StdOut.
  adr     X1, helloworld   // String to print.
  mov     X2, #13          // Length of our string.
  mov     X16, #4          // MacOS write system call.
  svc     0                // Call linux to output the string.
	RET		                   // Return to caller.
helloworld:      
  .ascii  "Hello World!\\n"
""";
}
// endregion