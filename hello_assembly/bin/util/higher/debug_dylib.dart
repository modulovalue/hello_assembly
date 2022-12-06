import 'binary_to_objdump.dart';
import 'dylib_to_exports.dart';

void debug_dylib({
  required final String dylib_path,
}) {
  print(
    binary_to_objdump(
      input: dylib_path,
    ),
  );
  print(
    "Here are the exports provided by the dylib: \n" +
        dylib_to_exports(
          input: dylib_path,
        ),
  );
}
