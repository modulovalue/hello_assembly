// ignore: deprecated_member_use
import 'dart:cli';
import 'dart:io';

String run_to_get(
  final String command,
  final List<String> args,
) {
  return Process.runSync(command, args).stdout.toString().trim();
}

/// Prints, and runs the given command with the given arguments.
void run(
  final String command,
  final List<String> args,
) {
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
