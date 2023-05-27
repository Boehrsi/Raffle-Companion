import 'dart:convert';
import 'dart:io';

Future<String> loadFileAsString(String path) async {
  final file = File(path);
  return await file.readAsString();
}

Future<void> saveData(String path, var data) async {
  final file = File(path);
  final content = jsonEncode(data);
  await file.writeAsString(content);
}
