
import '../basic/run.dart';

/// Compiles assembly to an object file.
///
/// Returns the output path.
String assembly_to_object({
  required final String input,
  required final String output,
}) {
  run_command(
    command: "as",
    args: [
      "-arch",
      "arm64",
      input,
      "-o",
      output,
    ],
  );
  return output;
}
