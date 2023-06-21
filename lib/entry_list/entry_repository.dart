import 'dart:convert';

import '../types/entry.dart';
import '../utils/files.dart';
import '../utils/json.dart';
import '../utils/logger.dart';

class EntryRepository {
  static final _instance = EntryRepository._internal();

  final _entryList = <Entry>[];
  final _logger = Logger();
  final _entryListFilePath = RaffleFile.entries.getFilePath();

  var _initialized = false;

  bool get initialized => _initialized;

  factory EntryRepository() => _instance;

  EntryRepository._internal();

  List<Entry> getEntryList({bool used = false, String searchTerm = ''}) =>
      _entryList.where((entry) => entry.used == used && _matchesSearch(searchTerm, entry)).toList();

  void addEntry(Entry addEntry) {
    _entryList.add(addEntry);
    _sortEntryList();
    _logger.add(Action.add, addEntry);
  }

  void editEntry(Entry editEntry, {String? name, String? key, String? platform, bool? used, String? tag}) {
    if (name != null) {
      editEntry.name = name;
    }
    if (key != null) {
      editEntry.key = key;
    }
    if (platform != null) {
      editEntry.platform = platform;
    }
    if (used != null) {
      editEntry.used = used;
    }
    if (tag != null) {
      editEntry.tag = tag;
    }
    _logger.add(Action.edit, editEntry);
  }

  void deleteEntry(Entry deleteEntry) {
    _entryList.remove(deleteEntry);
    _logger.add(Action.delete, deleteEntry);
  }

  Future<void> persistData() async => await saveData(_entryListFilePath, _entryList);

  Future<void> loadData() async {
    final content = await loadFileAsString(_entryListFilePath);
    List<dynamic> json = jsonDecode(content);
    for (var entryJson in json) {
      _entryList.add((Entry.fromJson(entryJson)));
    }
    _sortEntryList();
    _initialized = true;
  }

  bool _matchesSearch(String searchTerm, Entry entry) {
    final sanitizedSearchTerm = searchTerm.toLowerCase();
    return (searchTerm.isEmpty ||
        entry.name.toLowerCase().contains(sanitizedSearchTerm) ||
        entry.platform.toLowerCase().contains(sanitizedSearchTerm) ||
        entry.tag?.toLowerCase().contains(sanitizedSearchTerm) == true);
  }

  void _sortEntryList() {
    _entryList.sort((first, second) => first.name.toLowerCase().compareTo(second.name.toLowerCase()));
  }
}
