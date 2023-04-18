// create a new file that's a copy of the lambda_main_template.dart,
// except that imports the user's file which contains the shelf handler

import 'dart:io';

void main(List<String> args) {
  if (args.length < 1) {
    print('Usage: dart add_import.dart <source_file>');
    return;
  }

  final sourceFile = File(args[0]);
  // final destFile = File(args[1]);
  final destFile = File("lambda_main.dart");

  // Read the contents of the source file.
  final sourceContents = sourceFile.readAsStringSync();

  // Create a new file with the contents of the source file.
  destFile.writeAsStringSync(sourceContents);

  // Add an import statement for the source file to the new file.
  final importLine = "import '${sourceFile.path}' as my_server;\n";
  final destContents = importLine + sourceContents;
  destFile.writeAsStringSync(destContents);
}
