import 'dart:io';

/// Writes the given file to disk.
///
/// Returns the given filename.
String string_to_file({
  required final String path,
  required final String content,
}) {
  File(
    path,
  ).writeAsString(
    content,
  );
  return path;
}
