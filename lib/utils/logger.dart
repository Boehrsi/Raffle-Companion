import 'dart:convert';
import 'dart:io';

import '../utils/files.dart';

enum Action {
  start,
  add,
  edit,
  delete,
}

class Logger<T> {
  final _logFile = File(RaffleFile.log.getFilePath());

  IOSink? _sink;

  Logger() {
    _sink = _logFile.openWrite(mode: FileMode.append);
    _sink!.write('[${DateTime.now()}] ${Action.start}\n');
  }

  void add(Action action, T entry) {
    final json = jsonEncode(entry);
    _sink!.write('[${DateTime.now()}] $action\n$json\n');
  }

  void close() {
    _sink?.close();
  }
}
