import 'dart:ffi';

import '../commander/commands.dart';
import '../commander/runner.dart';

void main() {
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
    mov x0, #42
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
  final popcount =
      dylib.lookupFunction<Int64 Function(Int64), int Function(int)>(
    'popcount',
  );
  const iterations = 1000000;
  for (int i = 0; i < 20; i++) {
    print("=" * 80);
    measure(
      fn: () {
        int total = 0;
        for (int i = 0; i < iterations; i++) {
          total += popcount(i);
        }
        print(" - total: " + total.toString());
      },
      name: "   => via assembly",
    );
    measure(
      fn: () {
        int total = 0;
        for (int i = 0; i < iterations; i++) {
          total += count_bits_64_popcount(i);
        }
        print(" - total: " + total.toString());
      },
      name: "   => via lookup table",
    );
    measure(
      fn: () {
        int total = 0;
        for (int i = 0; i < iterations; i++) {
          total += i;
        }
        print(" - total: " + total.toString());
      },
      name: "   => id control",
    );
    measure(
      fn: () {
        int total = 0;
        for (int i = 0; i < iterations; i++) {
          total += id(i);
        }
        print(" - total: " + total.toString());
      },
      name: "   => id control with function call",
    );
    print("=" * 80);
  }

}

int count_bits_64_popcount(
  final int value_64_bits,
) {
  const lookup_table = "\x00\x01\x01\x02\x01\x02\x02\x03\x01\x02\x02\x03"
      "\x02\x03\x03\x04\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04"
      "\x04\x05\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05"
      "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06\x01\x02"
      "\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05\x02\x03\x03\x04"
      "\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06\x02\x03\x03\x04\x03\x04"
      "\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06\x03\x04\x04\x05\x04\x05\x05\x06"
      "\x04\x05\x05\x06\x05\x06\x06\x07\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03"
      "\x03\x04\x03\x04\x04\x05\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05"
      "\x04\x05\x05\x06\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05"
      "\x05\x06\x03\x04\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07"
      "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06\x03\x04"
      "\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07\x03\x04\x04\x05"
      "\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07\x04\x05\x05\x06\x05\x06"
      "\x06\x07\x05\x06\x06\x07\x06\x07\x07\x08";
  return lookup_table.codeUnitAt(value_64_bits & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 8) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 16) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 24) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 32) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 40) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 48) & 0xFF) +
      lookup_table.codeUnitAt((value_64_bits >>> 56) & 0xFF);
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
