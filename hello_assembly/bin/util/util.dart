// ignore: deprecated_member_use
import 'dart:cli';
import 'dart:io';
import 'dart:isolate';
import 'dart:mirrors';

/// Given a [type] returns the Directory of the file where it was declared.
Directory self_dir(
  final Type type,
) {
  return File(
    // ignore: deprecated_member_use
    waitFor(
      Isolate.resolvePackageUri(
        reflectType(
          type,
        ).location!.sourceUri,
      ),
    )!
        .path,
  ).parent;
}
