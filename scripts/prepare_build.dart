import 'dart:io';

import 'package:io/io.dart';

void main() async {
  await copyConfigFiles();
}

Future<void> copyConfigFiles() async {
  const source = "./files";
  const target = "./build/windows/x64/runner/Release/files";
  await Directory(target).create(recursive: true);
  await copyPath(source, target);
}
