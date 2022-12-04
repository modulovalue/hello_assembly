import '../basic/run_to_output.dart';

String binary_to_objdump({
  required final String input,
}) {
  return "Here's the output of objdump: \n" +
      run_to_output(
        command: "objdump",
        args: ["-d", "-s", input],
      );
}
