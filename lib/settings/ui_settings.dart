import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/root/root_cubit.dart';

import '../l10n/l10n.dart';
import '../l10n/locale_keys.g.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../utils/colors.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class UiSettings extends StatefulWidget {
  const UiSettings({Key? key}) : super(key: key);

  @override
  State<UiSettings> createState() => _UiSettingsState();
}

class _UiSettingsState extends State<UiSettings> {
  late FormComboBox _languageComboBox;
  late FormComboBox _themeComboBox;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupBoxes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RootCubit, RootState>(
      listener: (BuildContext context, RootState state) => context.read<SettingsCubit>().updateSettingsState(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          if (state is SettingsSuccess) {
            return ScaffoldPage(
              header: PageHeader(
                title: Text(LocaleKeys.ui.tr()),
              ),
              content: Center(
                child: ConstraintWidthContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LargeLabel(label: LocaleKeys.uiLanguage.tr()),
                        ConstraintWidthInput(child: _languageComboBox),
                        LargeLabel(label: LocaleKeys.uiTheme.tr()),
                        ConstraintWidthInput(child: _themeComboBox),
                        const LayoutSpacer(),
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
      ),
    );
  }

  void _setupBoxes() {
    _languageComboBox = FormComboBox(onChanged: (value) {
      if (value != null) _changeLanguageSelection(value);
    });
    final currentLanguage = getUserVisibleLocaleString(context.locale.languageCode);
    _languageComboBox.controller.setup(currentLanguage, kLocales.keys);
    _themeComboBox = FormComboBox(onChanged: (value) {
      if (value != null) _changeThemeSelection(value);
    });
    final currentBrightness = context.read<RootCubit>().theme.key.tr();
    final availableBrightness = kThemes.keys.map((element) => element.tr());
    _themeComboBox.controller.setup(currentBrightness, availableBrightness);
  }

  void _changeLanguageSelection(String value) {
    context.setLocale(kLocales[value]!);
    context.read<SettingsCubit>().updateSettingsState();
  }

  void _changeThemeSelection(String theme) {
    context.read<RootCubit>().add(SetTheme(theme));
  }
}
