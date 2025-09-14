import '../types/entry.dart';

abstract class EntryListState {}

class EntryListInitial extends EntryListState {}

class EntryListSuccess extends EntryListState {
  final List<Entry> entryList;
  final List<Entry> selectedList;
  final String searchTerm;
  final bool used;

  EntryListSuccess({
    required this.entryList,
    required this.selectedList,
    required this.searchTerm,
    required this.used,
  });

  EntryListSuccess copyWith({
    List<Entry>? entryList,
    List<Entry>? selectedList,
    String? searchTerm,
    bool? used,
  }) {
    return EntryListSuccess(
      entryList: entryList ?? this.entryList,
      selectedList: selectedList ?? this.selectedList,
      searchTerm: searchTerm ?? this.searchTerm,
      used: used ?? this.used,
    );
  }
}
