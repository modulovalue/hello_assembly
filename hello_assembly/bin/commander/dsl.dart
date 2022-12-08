// region commander
// region interface
abstract class Commander {
  R match<R>({
    required final R Function(Commander_Commands) composite,
  });
}
// endregion

// region commander commands
abstract class Commander_Commands implements Commander {
  Iterable<Command> get commands;
}

mixin Commander_Commands_Mixin implements Commander_Commands {
  @override
  R match<R>({
    required final R Function(Commander_Commands) composite,
  }) => composite(this);
}
// endregion
// endregion

// region command
// region interface
abstract class Command {
  R match<R>({
    required final R Function(Command_Process) process,
    required final R Function(Command_WriteString) write_string,
  });
}
// endregion

// region process
abstract class Command_Process implements Command {
  String get command;

  List<String> get args;
}

mixin Command_Process_Mixin implements Command_Process {
  @override
  R match<R>({
    required final R Function(Command_Process) process,
    required final R Function(Command_WriteString) write_string,
  }) => process(this);
}
// endregion

// region write string
abstract class Command_WriteString implements Command {
  String get path;

  String get content;
}

mixin Command_WriteString_Mixin implements Command_WriteString {
  @override
  R match<R>({
    required final R Function(Command_Process) process,
    required final R Function(Command_WriteString) write_string,
  }) => write_string(this);
}
// endregion
// endregion