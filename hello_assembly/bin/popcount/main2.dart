import 'dart:ffi';

import '../commander/commands.dart';
import '../commander/runner.dart';

void main() {
  // // Force loading the dylib with RLTD_GLOBAL so that the
  // // Native benchmarks below can do process lookup.
  // dlopenGlobalPlatformSpecific(
  //   'native_functions',
  //   path: Platform.script.resolve('../native/out/').path,
  // );
  final filename = clean_dir(type: _Type, dir_name: "output") + "hello_dylib";
  final assembly_path = filename + ".s";
  final object_path = filename + ".o";
  final dylib_path = filename + ".dylib";
  run_Commander(
    commander: Commander_Commands_Impl(
      commands: [
        Command_WriteString_Impl(
          path: assembly_path,
          content: """
.p2align 2
.global _popcount
_popcount:
    // TODO
    mov x0, x1
    ret
""",
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
  run(
    DynamicLibrary.open(
      dylib_path,
    ),
  );
}

void run(
  final DynamicLibrary dylib,
) {
  int id(
    final int i,
  ) =>
      i;
  final popcount_leaf =
      dylib.lookupFunction<Uint32 Function(Uint32), int Function(int)>(
    'popcount',
    isLeaf: true,
  );
  final popcount_notleaf =
      dylib.lookupFunction<Uint32 Function(Uint32), int Function(int)>(
    'popcount',
    isLeaf: false,
  );
  const iterations = 1000000;
  measure(
    fn: () {
      int total = 0;
      for (int i = 0; i < iterations; i++) {
        total += popcount_notleaf(i);
      }
      print(" - total: " + total.toString());
    },
    name: "   => via assembly notleaf",
  );
  measure(
    fn: () {
      int total = 0;
      for (int i = 0; i < iterations; i++) {
        total += popcount_leaf(i);
      }
      print(" - total: " + total.toString());
    },
    name: "   => via assembly leaf",
  );
}

void measure({
  required final void Function() fn,
  required final String name,
}) {
  final s = Stopwatch();
  s.start();
  fn();
  s.stop();
  print(
    name + " took: " + (s.elapsedMicroseconds / 1000).toString() + "ms",
  );
}

abstract class _Type {}
