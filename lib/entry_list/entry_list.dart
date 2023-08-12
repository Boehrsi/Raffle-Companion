import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_keys.g.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../styles/text.dart';
import '../types/entry.dart';
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
            title: Text(showUsed ? LocaleKeys.entriesUsed.tr() : LocaleKeys.entriesAvailable.tr()),
            commandBar: CommandBar(
              primaryItems: [
                if (!showUsed) ...[
                  CommandBarButton(
                    icon: const Icon(FluentIcons.check_mark),
                    label: Text(LocaleKeys.markUsed.tr()),
                    onPressed: entriesSelected ? _markUsed : null,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.send),
                    label: Text(LocaleKeys.winnerNotify.tr()),
                    onPressed: entriesSelected ? _notifyWinners : null,
                  ),
                  const CommandBarSeparator(),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: Text(LocaleKeys.add.tr()),
                    onPressed: _changeEntryDialog,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.delete),
                    label: Text(LocaleKeys.delete.tr()),
                    onPressed: entriesSelected ? _showConfirmDeleteDialog : null,
                  ),
                ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ConstraintWidthInput(
                            child: TextFormBox(
                              controller: searchController,
                              onChanged: (term) => _search(term),
                              placeholder: LocaleKeys.entriesSearch.tr(),
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
                        Button(
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(FluentIcons.copy),
                              ),
                              Text(LocaleKeys.entriesExport.tr()),
                            ],
                          ),
                          onPressed: () => _copyListDialog(state.entryList),
                        )
                      ],
                    ),
                    if (showUsed) LargeLabel(label: LocaleKeys.entries.tr()),
                    if (!showUsed)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Expander(
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.entriesSelected.tr(args: [state.selectedList.length.toString()]),
                                style: context.titleLargeStyle,
                              ),
                              Button(
                                onPressed: entriesSelected ? _unselectAllEntries : null,
                                child: Text(LocaleKeys.unselect.tr()),
                              ),
                            ],
                          ),
                          content: Text(
                              state.selectedList.isEmpty ? LocaleKeys.entriesNothingSelect.tr() : state.selectedList.map((e) => e.name).join(", ")),
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
                                    message: "${LocaleKeys.key.tr()}: ${entry.key}",
                                    displayHorizontally: true,
                                    child: ListTile(
                                      title: Text(entry.name),
                                      subtitle: Text(subtitle),
                                      trailing: Button(
                                        child: Text(LocaleKeys.markNotUsed.tr()),
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
                                            child: Text(LocaleKeys.edit.tr()),
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
                    if (state.entryList.isEmpty) Center(child: Text(LocaleKeys.entriesEmpty.tr())),
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
    var text = "${LocaleKeys.platform.tr()}: ${entry.platform}";
    if (entry.tag != null) {
      text += " | ${LocaleKeys.tag.tr()}: ${entry.tag}";
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
      showErrorDialog(context: context, error: LocaleKeys.errorNoPreset.tr());
    }
  }

  void _showConfirmMarkNotUsedDialog(Entry entry) {
    showConfirmDialog(
            context: context,
            title: LocaleKeys.markNotUsed.tr(),
            content: LocaleKeys.entriesMarkNotUsedConfirm.tr(),
            positiveText: LocaleKeys.markNotUsed.tr())
        .then((bool? value) {
      if (value != null && value) {
        _markNotUsed(entry);
      }
    });
  }

  void _showConfirmDeleteDialog() {
    showConfirmDialog(
            context: context, title: LocaleKeys.delete.tr(), content: LocaleKeys.entriesDeleteConfirm.tr(), positiveText: LocaleKeys.delete.tr())
        .then((bool? value) {
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
          title: Text(LocaleKeys.entriesExport.tr()),
          content: Text(LocaleKeys.entriesCopyHint.tr(args: [count.toString()])),
          actions: <Widget>[
            Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(LocaleKeys.cancel.tr()),
            ),
            Button(
              onPressed: () {
                cubit.copy(false);
                _showCopySuccessSnackbar(context);
                Navigator.of(context).pop();
              },
              child: Text(LocaleKeys.entriesCopyHtml.tr()),
            ),
            Button(
              onPressed: () {
                cubit.copy(true);
                _showCopySuccessSnackbar(context);
                Navigator.of(context).pop();
              },
              child: Text(LocaleKeys.entriesCopyMarkdown.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showCopySuccessSnackbar(BuildContext context) {
    showSnackbar(
      context,
      InfoBar(
        title: Text(LocaleKeys.copied.tr()),
        content: Text(LocaleKeys.entriesClipboard.tr()),
      ),
    );
  }
}
