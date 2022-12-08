import 'dsl.dart';
import 'runner.dart';

// region commander
// region commander composite
class Commander_Commands_Impl with Commander_Commands_Mixin {
  @override
  final List<Command> commands;

  const Commander_Commands_Impl({
    required final this.commands,
  });
}
// endregion
// endregion

// region commands
// region process
// region binary
class Command_binary_Impl with Command_Process_Mixin {
  final String c;

  const Command_binary_Impl({
    required final this.c,
  });

  @override
  String get command => c;

  @override
  List<String> get args => [];
}
// endregion

// region as
class Command_as_Impl with Command_Process_Mixin {
  final String input;
  final String output;

  const Command_as_Impl({
    required final this.input,
    required final this.output,
  });

  @override
  String get command {
    return "as";
  }

  @override
  List<String> get args {
    return [
      "-arch",
      "arm64",
      input,
      "-o",
      output,
    ];
  }
}
// endregion

// region objdump
class Command_objdump_Impl with Command_Process_Mixin {
  final String input;

  const Command_objdump_Impl({
    required final this.input,
  });

  @override
  String get command {
    return "objdump";
  }

  @override
  List<String> get args {
    return [
      "-d",
      "-s",
      input,
    ];
  }
}
// endregion

// region nm
class Object_nm_Impl with Command_Process_Mixin {
  final String input;

  const Object_nm_Impl({
    required final this.input,
  });

  @override
  String get command {
    return "nm";
  }

  @override
  List<String> get args {
    return [
      "-gU",
      input,
    ];
  }
}
// endregion

// region link
class Command_ld_Impl with Command_Process_Mixin {
  final String output;
  final String input;

  const Command_ld_Impl({
    required final this.output,
    required final this.input,
  });

  @override
  String get command {
    return "ld";
  }

  @override
  List<String> get args {
    return [
      "-o",
      output,
      input,
      "-lSystem",
      "-syslibroot",
      // TODO how to represent this dependency.
      run_and_take_output_commander(
        const Command_xcrun_Impl(),
      ),
      "-e",
      "_start",
      "-arch",
      "arm64",
    ];
  }
}
// endregion

// region xcrun
class Command_xcrun_Impl with Command_Process_Mixin {
  const Command_xcrun_Impl();

  @override
  List<String> get args {
    return [
      "-sdk",
      "macosx",
      "--show-sdk-path",
    ];
  }

  @override
  String get command {
    return "xcrun";
  }
}
// endregion

// region clang
class Command_clang_Impl with Command_Process_Mixin {
  final String input;
  final String output;

  const Command_clang_Impl({
    required final this.input,
    required final this.output,
  });

  @override
  String get command {
    return "clang";
  }

  @override
  List<String> get args {
    return [
      "-current_version",
      "1.0",
      "-compatibility_version",
      "1.0",
      "-dynamiclib",
      "-o",
      output,
      input,
    ];
  }
}
// endregion
// endregion

// region write string
class Command_WriteString_Impl with Command_WriteString_Mixin {
  @override
  final String content;
  @override
  final String path;

  const Command_WriteString_Impl({
    required final this.content,
    required final this.path,
  });
}
// endregion
// endregion
