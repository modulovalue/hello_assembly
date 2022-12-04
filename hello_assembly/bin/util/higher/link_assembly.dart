import '../basic/run.dart';
import '../basic/run_to_output.dart';

/// Links the given object file with the system libraries.
///
/// Returns the given output path.
String link_assembly({
  required final String input,
  required final String output,
}) {
  run_command(
    command: "ld",
    args: [
      "-o",
      output,
      input,
      "-lSystem",
      "-syslibroot",
      run_to_output(
        command: "xcrun",
        args: ["-sdk", "macosx", "--show-sdk-path"],
      ),
      "-e",
      "_start",
      "-arch",
      "arm64",
    ],
  );
  return output;
}
