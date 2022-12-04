import '../basic/run_to_output.dart';

/// Returns a list of all the exports that can be found in the given dylib.
String dylib_to_exports({
  required final String input,
}) {
  return run_to_output(
    command: "nm",
    args: [
      "-gU",
      input,
    ],
  ).splitMapJoin(
    "\n",
    onNonMatch: (final a) => " * " + a,
  );
}
