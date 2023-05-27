import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprintf/sprintf.dart';

import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../styles/text.dart';
import '../types/type_definitions.dart';
import '../utils/l10n.dart';
import '../utils/text.dart';
import '../widgets/dialogs.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class MailPresetSettings extends StatefulWidget {
  const MailPresetSettings({Key? key}) : super(key: key);

  @override
  State<MailPresetSettings> createState() => _MailPresetSettingsState();
}

class _MailPresetSettingsState extends State<MailPresetSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameInputField = FormTextBox(label: kTextName, validator: validatorNotEmpty);
  final _textInputField = FormTextBox(label: kTextText, validator: _getPresetTextValidator, multiLine: true);
  late FormComboBox _mailPresetComboBox;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    _mailPresetComboBox = FormComboBox(onChanged: (value) {
      if (value != null) _changeDefaultSelection(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (BuildContext context, state) {
        if (state is SettingsSuccess) {
          final items = _getMailPresetNameList(state);
          _mailPresetComboBox.controller.setup(state.settings.defaultMailPreset, items);
        }
      },
      builder: (BuildContext context, state) {
        if (state is SettingsSuccess) {
          return ScaffoldPage(
            header: PageHeader(
              title: const Text(kTextMailPresetSettings),
              commandBar: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.noWrap,
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: const Text(kTextAdd),
                    onPressed: _changeMailPresetDialog,
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
                      if (state.mailPresetList.isNotEmpty) ...[
                        const LargeLabel(label: kTextMailPresetDefault),
                        ConstraintWidthInput(child: _mailPresetComboBox),
                        const LargeLabel(label: kTextMailPresetList),
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.mailPresetList.length,
                            itemBuilder: (context, index) {
                              return MailPresetTile(
                                name: state.mailPresetList[index].name,
                                text: state.mailPresetList[index].text,
                                onChange: _changeMailPresetDialog,
                                onDelete: (name) => _deleteMailPresetDialog(name, state.mailPresetList.length),
                              );
                            },
                            separatorBuilder: (context, index) {
                              if (index < state.mailPresetList.length) {
                                return const Divider();
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                      if (state.mailPresetList.isEmpty) const Center(child: Text(kTextEntriesEmpty)),
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

  Iterable<String> _getMailPresetNameList(SettingsSuccess state) => state.mailPresetList.map((value) => value.name);

  void _changeMailPresetDialog([String? name, String? text]) {
    _nameInputField.controller.clear();
    _textInputField.controller.clear();
    final isChange = name != null;
    if (isChange) {
      _nameInputField.controller.text = name;
      _textInputField.controller.text = text!;
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
              onPressed: () => _changeMailPreset(name),
              child: Text(isChange ? kTextEdit : kTextAdd),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _nameInputField,
              _textInputField,
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SelectableText(
                  kTextPresetMustContain,
                  style: context.captionStyle,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _showConfirmRestoreDialog() {
    showConfirmDialog(context: context, title: kTextRestore, content: kTextPresetRestoreConfirm, positiveText: kTextRestore).then((bool? value) {
      if (value != null && value) {
        restoreDefaults();
      }
    });
  }

  void _deleteMailPresetDialog(String name, int entryCount) {
    if (entryCount <= 1) {
      showInfoDialog(context: context, title: kTextErrorTitle, content: kTextSettingsCantDeleteLastEntry);
    } else {
      showConfirmDialog(context: context, title: kTextDelete, content: sprintf(kTextPresetDeleteConfirm, [name]), positiveText: kTextDelete)
          .then((shouldDelete) {
        if (shouldDelete == true) {
          _deleteMailPreset(name);
        }
      });
    }
  }

  void _changeMailPreset(String? name) {
    final currentName = name ?? _nameInputField.controller.text;
    if (_formKey.currentState!.validate()) {
      context.read<SettingsCubit>().changeMailPreset(currentName, _nameInputField.controller.text, _textInputField.controller.text);
      Navigator.pop(context);
    }
  }

  void _deleteMailPreset(String name) => context.read<SettingsCubit>().deleteMailPreset(name);

  void restoreDefaults() => context.read<SettingsCubit>().restoreMailPresets();

  void _changeDefaultSelection(String name) => context.read<SettingsCubit>().changeMailPresetDefaultSelection(name);
}

class MailPresetTile extends StatelessWidget {
  final String name;
  final String text;
  final OnMailPresetChange onChange;
  final OnMailPresetDelete onDelete;

  const MailPresetTile({Key? key, required this.name, required this.text, required this.onChange, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Button(
              child: const Text(kTextEdit),
              onPressed: () => onChange(name, text),
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

String? _getPresetTextValidator(value) {
  if (value == null || value.isEmpty) {
    return kTextErrorNotEmpty;
  } else if (!value.contains('%RAFFLE_NAME%') || !value.contains('%RAFFLE_URL%') || !value.contains('%PRODUCT%') || !value.contains('%KEY%')) {
    return kTextErrorPresetMustContain;
  }
  return null;
}
