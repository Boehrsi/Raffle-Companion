import 'package:flutter_bloc/flutter_bloc.dart';

import '../entry_list/entry_repository.dart';
import '../types/entry.dart';
import '../utils/system_interaction.dart';
import 'entry_list_state.dart';

class EntryListCubit extends Cubit<EntryListState> {
  final _repository = EntryRepository();

  EntryListSuccess get _successState => (state as EntryListSuccess);

  EntryListCubit() : super(EntryListInitial());

  Future<void> loadData(bool showUsed) async {
    if (!_repository.initialized) {
      await _repository.loadData();
    }
    _delegateSuccess(used: showUsed);
  }

  void search(String term) => _delegateSuccess(searchTerm: term);

  void resetSearch() => _delegateSuccess(searchTerm: '');

  void select(Entry entry, bool selected) {
    final selectedList = state is EntryListSuccess ? _successState.selectedList : <Entry>[];
    if (selected) {
      selectedList.add(entry);
    } else {
      selectedList.remove(entry);
    }
    _delegateSuccess(selectedList: selectedList);
  }

  void unselectAll() => _delegateSuccess(selectedList: <Entry>[]);

  Future<void> copy(bool isMarkdown) async => await copyToClipboard(_successState.entryList, isMarkdown);

  Future<void> add(String name, String key, String platform, String tag) async {
    final entry = Entry(name, key, platform, tag);
    _repository.addEntry(entry);
    await _repository.persistData();
    _delegateSuccess();
  }

  Future<void> edit(Entry editEntry, String name, String key, String platform, String tag) async {
    _repository.editEntry(editEntry, name: name, key: key, platform: platform, tag: tag);
    await _repository.persistData();
    _delegateSuccess();
  }

  Future<void> markUsed() async {
    for (Entry entry in _successState.selectedList) {
      _repository.editEntry(entry, used: true);
    }
    await _repository.persistData();
    unselectAll();
  }

  Future<void> markNotUsed(Entry entry) async {
    _repository.editEntry(entry, used: false);
    await _repository.persistData();
    _delegateSuccess();
  }

  Future<void> delete() async {
    for (Entry entry in _successState.selectedList) {
      _repository.deleteEntry(entry);
    }
    await _repository.persistData();
    unselectAll();
  }

  void _delegateSuccess({List<Entry>? selectedList, String? searchTerm, bool? used}) {
    if (state is! EntryListSuccess) {
      emit(EntryListSuccess(entryList: _repository.getEntryList(), selectedList: <Entry>[], searchTerm: '', used: false));
    } else {
      final entryList = _reloadEntries(searchTerm ?? _successState.searchTerm, used ?? _successState.used);
      emit(_successState.copyWith(
        entryList: entryList,
        selectedList: selectedList,
        searchTerm: searchTerm,
        used: used,
      ));
    }
  }

  List<Entry> _reloadEntries(String searchTerm, bool used) => _repository.getEntryList(searchTerm: searchTerm, used: used);
}
