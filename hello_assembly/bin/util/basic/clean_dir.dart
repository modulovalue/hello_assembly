import 'dart:io';

import 'self_dir.dart';

/// Return a path to the given directory.
///
/// Clears the directory if it already exists.
String clean_dir({
  required final Type type,
  required final String dir_name,
}) {
  final dir = self_dir(type);
  final root_dir_path = dir.absolute.path + "/" + dir_name + "/";
  final root_dir = Directory(root_dir_path);
  if (root_dir.existsSync()) {
    root_dir.deleteSync(recursive: true);
  }
  root_dir.createSync();
  return root_dir_path;
}
