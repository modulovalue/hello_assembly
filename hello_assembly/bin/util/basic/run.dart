// ignore: deprecated_member_use
import 'dart:cli';
import 'dart:io';

/// Prints, and runs the given command with the given arguments.
void run_command({
  required final String command,
  final List<String> args = const <String>[],
}) {
  print(
    "Running: '$command ${args.join(" ")}'",
  );
  // ignore: deprecated_member_use
  waitFor(
    Process.start(
      command,
      args,
      mode: ProcessStartMode.inheritStdio,
    ).then(
      (final value) => value.exitCode,
    ),
  );
}
