import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprintf/sprintf.dart';

import '../types/type_definitions.dart';
import '../utils/l10n.dart';
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
  final _nameInputField = FormTextBox(label: kTextPlatform, validator: validatorNotEmpty);
  late FormComboBox _platformComboBox;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    _platformComboBox = FormComboBox(onChanged: (value) {
      if (value != null) _changeDefaultSelection(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(listener: (BuildContext context, state) {
      if (state is SettingsSuccess) {
        final items = _getPlatformNameList(state);
        _platformComboBox.controller.setup(state.settings.defaultPlatform, items);
      }
    }, builder: (BuildContext context, state) {
      if (state is SettingsSuccess) {
        return ScaffoldPage(
          header: PageHeader(
            title: const Text(kTextPlatformSettings),
            commandBar: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.add),
                  label: const Text(kTextAdd),
                  onPressed: _changePlatformDialog,
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.reset),
                  label: const Text(kTextRestoreDefaults),
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
                      const LargeLabel(label: kTextPlatformDefault),
                      ConstraintWidthInput(child: _platformComboBox),
                      const LargeLabel(label: kTextPlatformList),
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
                    if (state.platformList.isEmpty) const Center(child: Text(kTextEntriesEmpty)),
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

  Iterable<String> _getPlatformNameList(SettingsSuccess state) => state.platformList.map((value) => value.name);

  void _showConfirmRestoreDialog() {
    showConfirmDialog(context: context, title: kTextRestore, content: kTextPlatformRestoreConfirm, positiveText: kTextRestore).then((bool? value) {
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
            title: isChange ? kTextEdit : kTextAdd,
            actions: [
              Button(
                onPressed: () => Navigator.pop(context),
                child: const Text(kTextCancel),
              ),
              Button(
                onPressed: () => _changePlatform(name),
                child: Text(isChange ? kTextEdit : kTextAdd),
              ),
            ],
            child: _nameInputField);
      },
    );
  }

  void _deletePlatformDialog(String name, int entryCount) {
    if (entryCount <= 1) {
      showInfoDialog(context: context, title: kTextErrorTitle, content: kTextSettingsCantDeleteLastEntry);
    } else {
      showConfirmDialog(
        context: context,
        title: kTextDelete,
        content: sprintf(kTextPlatformDeleteConfirm, [name]),
        positiveText: kTextDelete,
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
              child: const Text(kTextEdit),
              onPressed: () => onChange(name),
            ),
          ),
          Button(
            child: const Text(kTextDelete),
            onPressed: () => onDelete(name),
          ),
        ],
      ),
    );
  }
}
