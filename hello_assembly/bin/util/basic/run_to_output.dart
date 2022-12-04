import 'dart:io';

/// Calls the given command with the given arguments.
///
/// Returns its trimmed output.
String run_to_output({
  required final String command,
  required final List<String> args,
}) {
  return Process.runSync(
    command,
    args,
  ).stdout.toString().trim();
}
