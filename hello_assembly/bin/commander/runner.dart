// ignore: deprecated_member_use
import 'dart:cli';
import 'dart:io';

// ignore: deprecated_member_use
import 'dart:isolate';
import 'dart:mirrors';

import 'dsl.dart';

// TODO support setting a working directory root to have shorter paths.
// TODO support running runar dsls.
// TODO support cleaning as a step?
void run_Commander({
  required final Commander commander,
}) {
  void _actual_run(
    final Commander_Commands a,
  ) {
    for (final b in a.commands) {
      b.match(
        write_string: (final a) {
          File(
            a.path,
          ).writeAsString(
            a.content,
          );
        },
        process: (final a) {
          // ignore: deprecated_member_use
          waitFor(
            Process.start(
              a.command,
              a.args,
              mode: ProcessStartMode.inheritStdio,
            ).then(
              (final value) => value.exitCode,
            ),
          );
        },
      );
    }
  }

  void _announce(
    final Commander_Commands a,
  ) {
    print(
      "Running a commands commander. Here's the plan: ",
    );
    for (final b in a.commands) {
      b.match(
        write_string: (final a) {
          print(
            " * Writing file to:" + a.path + "'",
          );
        },
        process: (final a) {
          print(
            " * Run command: '" + a.command + " " + a.args.join(" ") + "'",
          );
        },
      );
    }
  }

  commander.match(
    composite: (final a) {
      _announce(a);
      _actual_run(a);
    },
  );
}

// TODO remove this once I support runar dsls and commands have safe outputs.
String run_and_take_output_commander(
  final Command_Process commander,
) {
  return Process.runSync(
    commander.command,
    commander.args,
  ).stdout.toString().trim();
}

// TODO remove this once interpreter can support it.
// TODO  or maybe add this as a step?
/// Return a path to the given directory.
///
/// Clears the directory if it already exists.
String clean_dir({
  required final Type type,
  required final String dir_name,
}) {
  Directory _self_dir(
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

  final dir = _self_dir(type);
  final root_dir_path = dir.absolute.path + "/" + dir_name + "/";
  final root_dir = Directory(root_dir_path);
  if (root_dir.existsSync()) {
    root_dir.deleteSync(recursive: true);
  }
  root_dir.createSync();
  return root_dir_path;
}
