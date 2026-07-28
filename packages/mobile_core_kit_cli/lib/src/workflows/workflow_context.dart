import 'dart:io';

import 'package:path/path.dart' as p;

typedef WorkflowCommandExecutor = Future<int> Function(List<String> command);

class WorkflowContext {
  WorkflowContext({
    required this.rootDirectory,
    required this.execute,
    StringSink? output,
    StringSink? errorOutput,
  }) : output = output ?? stdout,
       errorOutput = errorOutput ?? stderr;

  final Directory rootDirectory;
  final WorkflowCommandExecutor execute;
  final StringSink output;
  final StringSink errorOutput;

  File file(String relativePath) =>
      File(p.join(rootDirectory.path, relativePath));

  Directory directory(String relativePath) =>
      Directory(p.join(rootDirectory.path, relativePath));

  Future<int> step(String title, List<String> command) async {
    output.writeln('\n==> $title');
    return execute(command);
  }

  Future<int> workflowStep(
    String title,
    Future<int> Function() workflow,
  ) async {
    output.writeln('\n==> $title');
    return workflow();
  }
}
