import '../basic/run.dart';

/// Converts the given object to a dylib.
///
/// Returns the output path.
String object_to_dylib({
  required final String input,
  required final String output,
}) {
  run_command(
    command: "clang",
    args: [
      "-current_version",
      "1.0",
      "-compatibility_version",
      "1.0",
      "-dynamiclib",
      "-o",
      output,
      input,
    ],
  );
  return output;
}
