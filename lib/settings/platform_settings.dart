import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_keys.g.dart';
import '../types/type_definitions.dart';
import '../utils/text.dart';
import '../widgets/dialogs.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';

class PlatformSettings extends StatefulWidget {
  const PlatformSettings({Key? key}) : super(key: key);

  @override
  State<PlatformSettings> createState() => _PlatformSettingsState();
}

class _PlatformSettingsState extends State<PlatformSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameInputField = FormTextBox(label: LocaleKeys.platform.tr(), validator: validatorNotEmpty);
  late FormComboBox _platformComboBox;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupPlatformBox();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (BuildContext context, state) {
        if (state is SettingsSuccess) {
          return ScaffoldPage(
            header: PageHeader(
              title: Text(LocaleKeys.platformSettings.tr()),
              commandBar: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.noWrap,
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: Text(LocaleKeys.add.tr()),
                    onPressed: _changePlatformDialog,
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.reset),
                    label: Text(LocaleKeys.restoreDefaults.tr()),
                    onPressed: _showConfirmRestoreDialog,
                  ),
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
                      if (state.platformList.isNotEmpty) ...[
                        LargeLabel(label: LocaleKeys.platformDefault.tr()),
                        ConstraintWidthInput(child: _platformComboBox),
                        LargeLabel(label: LocaleKeys.platforms.tr()),
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.platformList.length,
                            itemBuilder: (context, index) {
                              return PlatformTile(
                                name: state.platformList[index].name,
                                onChange: _changePlatformDialog,
                                onDelete: (name) => _deletePlatformDialog(name, state.platformList.length),
                              );
                            },
                            separatorBuilder: (context, index) {
                              if (index < state.platformList.length) {
                                return const Divider();
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                      if (state.platformList.isEmpty) Center(child: Text(LocaleKeys.entriesEmpty.tr())),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: ProgressRing());
        }
      },
    );
  }

  void _setupPlatformBox() {
    _platformComboBox = FormComboBox(onChanged: (value) {
      if (value != null) _changeDefaultSelection(value);
    });
    final state = context.read<SettingsCubit>().state;
    if (state is SettingsSuccess) {
      final items = state.platformList.map((value) => value.name);
      _platformComboBox.controller.setup(state.settings.defaultPlatform, items);
    }
  }

  void _showConfirmRestoreDialog() {
    showConfirmDialog(
            context: context, title: LocaleKeys.restore.tr(), content: LocaleKeys.platformRestoreConfirm.tr(), positiveText: LocaleKeys.restore.tr())
        .then((bool? value) {
      if (value != null && value) {
        _restoreDefaults();
      }
    });
  }

  void _changePlatformDialog([String? name]) {
    _nameInputField.controller.clear();
    final isChange = name != null;
    if (isChange) {
      _nameInputField.controller.text = name;
    }
    showDialog(
      context: context,
      builder: (context) {
        return FormDialog(
            formKey: _formKey,
            title: isChange ? LocaleKeys.edit.tr() : LocaleKeys.add.tr(),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              Button(
                onPressed: () => _changePlatform(name),
                child: Text(isChange ? LocaleKeys.edit.tr() : LocaleKeys.add.tr()),
              ),
            ],
            child: _nameInputField);
      },
    );
  }

  void _deletePlatformDialog(String name, int entryCount) {
    if (entryCount <= 1) {
      showInfoDialog(context: context, title: LocaleKeys.errorTitle.tr(), content: LocaleKeys.settingsCantDeleteLastEntry.tr());
    } else {
      showConfirmDialog(
        context: context,
        title: LocaleKeys.delete.tr(),
        content: LocaleKeys.platformDeleteConfirm.tr(args: [name]),
        positiveText: LocaleKeys.delete.tr(),
      ).then((shouldDelete) {
        if (shouldDelete == true) {
          _deletePlatform(name);
        }
      });
    }
  }

  void _changePlatform(String? name) {
    final currentName = name ?? _nameInputField.controller.text;
    if (_formKey.currentState!.validate()) {
      context.read<SettingsCubit>().changePlatform(currentName, _nameInputField.controller.text);
      Navigator.pop(context);
    }
  }

  void _deletePlatform(String name) => context.read<SettingsCubit>().deletePlatform(name);

  void _restoreDefaults() => context.read<SettingsCubit>().restorePlatforms();

  void _changeDefaultSelection(String name) => context.read<SettingsCubit>().changePlatformDefaultSelection(name);
}

class PlatformTile extends StatelessWidget {
  final String name;
  final OnPlatformChange onChange;
  final OnPlatformDelete onDelete;

  const PlatformTile({Key? key, required this.name, required this.onChange, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Button(
              child: Text(LocaleKeys.edit.tr()),
              onPressed: () => onChange(name),
            ),
          ),
          Button(
            child: Text(LocaleKeys.delete.tr()),
            onPressed: () => onDelete(name),
          ),
        ],
      ),
    );
  }
}
