import 'dart:cli';
import 'dart:io';
import 'dart:isolate';
import 'dart:mirrors';

Future<void> main() async {
  const assembly = r"""
  section  .data
message: db    "Hello, World", 0Ah, 00h
  global  _main
  section  .text
_main:
  mov    rax, 0x02000004    ; system call for write
  mov    rdi, 1             ; file descriptor 1 is stdout
  mov    rsi, qword message ; get string address
  mov    rdx, 13            ; number of bytes
  syscall                   ; execute syscall (write)
  mov    rax, 0x02000001    ; system call for exit
  mov    rdi, 0             ; exit code 0
  syscall                   ; execute syscall (exit)
""";
  // region housekeeping
  final dir = self_dir(_Type);
  final root_dir_path = dir.absolute.path + "/output/";
  final root_dir = Directory(root_dir_path);
  if (root_dir.existsSync()) {
    root_dir.deleteSync(recursive: true);
  }
  root_dir.createSync();
  // endregion
  final filename = root_dir_path + "hello_intel";
  final asm_filename = filename + ".asm";
  final asm_o_filename = filename + ".o";
  final binary_filename = filename + ".exe";
  // region write
  File(
    asm_filename,
  ).writeAsString(
    assembly,
  );
  // endregion
  // region compile
  await Process.start(
    "yasm",
    [
      "-f",
      "macho64",
      asm_filename,
      "-o",
      asm_o_filename,
    ],
    mode: ProcessStartMode.inheritStdio,
  ).then((value) => value.exitCode);
  // endregion
  // region link
  await Process.start(
    "ld",
    [
      "-lSystem",
      "-o",
      binary_filename,
      asm_o_filename,
    ],
    mode: ProcessStartMode.inheritStdio,
  ).then((value) => value.exitCode);
  // endregion
  // region run
  await Process.start(
    binary_filename,
    [],
    mode: ProcessStartMode.inheritStdio,
  ).then((value) => value.exitCode);
  // endregion
}

// region path hack
abstract class _Type {}

/// Given a [type] returns the file
/// where it was declared.
Directory self_dir(
  final Type type,
) {
  return File(
    // ignore: deprecated_member_use
    waitFor(
      Isolate.resolvePackageUri(
        reflectType(
          type,
        ).location!.sourceUri,
      ),
    )!
        .path,
  ).parent;
}
// endregion
