import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    print('Usage: dart add_handler.dart <filename> <handlername>');
    exit(1);
  }

  final file = args[0];
  final tempFile = File('${file}.temp');
  final handlerName = args[1];
  final handlerDeclaration = 'Handler $handlerName;';

  try {
    // Create temporary file
    tempFile.createSync();

    // Copy contents of original file to temporary file, inserting handler declaration
    final lines = File(file).readAsLinesSync();
    final mainLine =
        lines.indexWhere((line) => line.trim().startsWith('void main('));
    final newLines = [
      ...lines.sublist(0, mainLine),
      handlerDeclaration,
      ...lines.sublist(mainLine),
    ];
    tempFile.writeAsStringSync(newLines.join('\n'));

    // Replace original file with temporary file
    final originalFile = File(file);
    originalFile.writeAsStringSync(tempFile.readAsStringSync());
  } finally {
    // Delete temporary file
    tempFile.deleteSync();
  }
}
