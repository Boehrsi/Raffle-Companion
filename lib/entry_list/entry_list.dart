import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprintf/sprintf.dart';

import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../styles/text.dart';
import '../types/entry.dart';
import '../utils/l10n.dart';
import '../widgets/dialogs.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';
import '../winners/notify_winners.dart';
import 'entry_list_change.dart';
import 'entry_list_cubit.dart';
import 'entry_list_state.dart';

class EntryList extends StatefulWidget {
  final bool showUsed;

  const EntryList({required this.showUsed, Key? key}) : super(key: key);

  @override
  State<EntryList> createState() => _EntryListState();
}

class _EntryListState extends State<EntryList> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    final entryListCubit = context.read<EntryListCubit>();
    entryListCubit.loadData(widget.showUsed);
    entryListCubit.resetSearch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntryListCubit, EntryListState>(builder: (context, state) {
      if (state is EntryListSuccess) {
        final showUsed = widget.showUsed;
        final entriesSelected = state.selectedList.isNotEmpty;
        return ScaffoldPage(
          header: PageHeader(
            title: Text(showUsed ? kTextEntriesUsed : kTextEntries),
            commandBar: CommandBar(
              primaryItems: [
                if (!showUsed) ...[
                  CommandBarButton(
                    icon: const Icon(FluentIcons.check_mark),
                    label: const Text(kTextMarkUsed),
                    onPressed: entriesSelected ? _markUsed : null,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.send),
                    label: const Text(kTextWinnerNotify),
                    onPressed: entriesSelected ? _notifyWinners : null,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.delete),
                    label: const Text(kTextDelete),
                    onPressed: entriesSelected ? _showConfirmDeleteDialog : null,
                  ),
                  const CommandBarSeparator(),
                ],
                if (!showUsed) ...[
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: const Text(kTextAdd),
                    onPressed: _changeEntryDialog,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.copy),
                    label: const Text(kTextEntriesExport),
                    onPressed: () => _copyListDialog(state.entryList),
                  ),
                ]
              ],
            ),
          ),
          content: Center(
            child: ConstraintWidthContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ConstraintWidthInput(
                        child: TextFormBox(
                          controller: searchController,
                          onChanged: (term) => _search(term),
                          placeholder: kTextEntriesSearch,
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(FluentIcons.search),
                          ),
                          suffix: IconButton(
                            icon: const Icon(FluentIcons.clear),
                            onPressed: () {
                              searchController.clear();
                              _search("");
                            },
                          ),
                        ),
                      ),
                    ),
                    if (showUsed) const LargeLabel(label: kTextEntries),
                    if (!showUsed)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Expander(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sprintf(kTextEntriesSelected, [state.selectedList.length]),
                                style: context.titleLargeStyle,
                              ),
                              Button(
                                onPressed: entriesSelected ? _unselectAllEntries : null,
                                child: const Text(kTextUnselect),
                              ),
                            ],
                          ),
                          content: Text(state.selectedList.isEmpty ? kTextEntriesNothingSelect : state.selectedList.map((e) => e.name).join(", ")),
                        ),
                      ),
                    if (state.entryList.isNotEmpty) ...[
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.entryList.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final entry = state.entryList[index];
                            final subtitle = _buildSubtitle(entry);
                            return showUsed
                                ? Tooltip(
                                    message: "$kTextKey: ${entry.key}",
                                    displayHorizontally: true,
                                    child: ListTile(
                                      title: Text(entry.name),
                                      subtitle: Text(subtitle),
                                      trailing: Button(
                                        child: const Text(kTextMarkNotUsed),
                                        onPressed: () => _showConfirmMarkNotUsedDialog(entry),
                                      ),
                                    ),
                                  )
                                : ListTile(
                                    leading: Icon(entry.key != null && entry.key!.isNotEmpty ? FluentIcons.encryption : FluentIcons.field_empty),
                                    title: Text(entry.name),
                                    subtitle: Text(subtitle),
                                    trailing: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Button(
                                            child: const Text(kTextEdit),
                                            onPressed: () => _changeEntryDialog(entry),
                                          ),
                                        ),
                                        Checkbox(
                                          checked: state.selectedList.contains(entry),
                                          onChanged: (value) => _selectEntry(entry, value),
                                        ),
                                      ],
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                    if (state.entryList.isEmpty) const Center(child: Text(kTextEntriesEmpty)),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        return const Center(child: ProgressRing());
      }
    });
  }

  String _buildSubtitle(Entry entry) {
    var text = "$kTextPlatform: ${entry.platform}";
    if (entry.tag != null) {
      text += " | $kTextTag: ${entry.tag}";
    }
    return text;
  }

  void _search(String term) => context.read<EntryListCubit>().search(term);

  void _changeEntryDialog([Entry? entry]) {
    final isChange = entry != null;
    showDialog(
      context: context,
      builder: (context) => isChange ? EntryListChange(entry: entry) : const EntryListChange(),
    );
  }

  void _selectEntry(Entry entry, bool? selected) {
    if (selected != null) {
      context.read<EntryListCubit>().select(entry, selected);
    }
  }

  void _unselectAllEntries() => context.read<EntryListCubit>().unselectAll();

  void _markUsed() => context.read<EntryListCubit>().markUsed();

  void _markNotUsed(Entry entry) => context.read<EntryListCubit>().markNotUsed(entry);

  void _notifyWinners() {
    final settingsCubit = context.read<SettingsCubit>();
    if (settingsCubit.state is SettingsSuccess && (settingsCubit.state as SettingsSuccess).mailPresetList.isNotEmpty) {
      Navigator.push(
        context,
        FluentPageRoute(
          builder: (context) => const NotifyWinners(),
        ),
      );
    } else {
      showErrorDialog(context: context, error: kTextErrorNoPreset);
    }
  }

  void _showConfirmMarkNotUsedDialog(Entry entry) {
    showConfirmDialog(context: context, title: kTextMarkNotUsed, content: kTextEntriesMarkNotUsedConfirm, positiveText: kTextMarkNotUsed)
        .then((bool? value) {
      if (value != null && value) {
        _markNotUsed(entry);
      }
    });
  }

  void _showConfirmDeleteDialog() {
    showConfirmDialog(context: context, title: kTextDelete, content: kTextEntriesDeleteConfirm, positiveText: kTextDelete).then((bool? value) {
      if (value != null && value) {
        _delete();
      }
    });
  }

  void _delete() => context.read<EntryListCubit>().delete();

  void _copyListDialog(List<Entry> entryList) {
    final cubit = context.read<EntryListCubit>();
    final count = entryList.uniqueNameList().length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContentDialog(
          title: const Text(kTextEntriesExport),
          content: Text(sprintf(kTextEntriesCopyHint, [count])),
          actions: <Widget>[
            Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(kTextCancel),
            ),
            Button(
              onPressed: () {
                cubit.copy(false);
                _showCopySuccessSnackbar(context);
                Navigator.of(context).pop();
              },
              child: const Text(kTextEntriesCopyHtml),
            ),
            Button(
              onPressed: () {
                cubit.copy(true);
                _showCopySuccessSnackbar(context);
                Navigator.of(context).pop();
              },
              child: const Text(kTextEntriesCopyMarkdown),
            ),
          ],
        );
      },
    );
  }

  void _showCopySuccessSnackbar(BuildContext context) {
    showSnackbar(
      context,
      const Snackbar(
        content: Text(kTextEntriesClipboard),
      ),
    );
  }
}
