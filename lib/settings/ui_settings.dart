import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/root/root_bloc.dart';

import '../l10n/l10n.dart';
import '../l10n/locale_keys.g.dart';
import '../utils/colors.dart';
import '../widgets/input.dart';
import '../widgets/layout.dart';
import '../widgets/text.dart';

class UiSettings extends StatefulWidget {
  const UiSettings({super.key});

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
    return BlocConsumer<RootBloc, RootState>(
      listener: (context, state) => _setupBoxes(),
      builder: (BuildContext context, RootState state) {
        if (state is RootSuccess) {
          return ScaffoldPage(
            header: PageHeader(title: Text(LocaleKeys.ui.tr())),
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
    );
  }

  void _setupBoxes() {
    _languageComboBox = FormComboBox(onChanged: _changeLanguageSelection);
    final currentLanguage = getUserVisibleLocaleString(
      context.locale.languageCode,
    );
    _languageComboBox.controller.setup(currentLanguage, kLocales.keys);
    _themeComboBox = FormComboBox(onChanged: _changeThemeSelection);
    final currentBrightness = context.read<RootBloc>().theme.key.tr();
    final availableBrightness = kThemes.keys.map((element) => element.tr());
    _themeComboBox.controller.setup(currentBrightness, availableBrightness);
  }

  void _changeLanguageSelection(String? value) {
    if (value != null) {
      context.setLocale(kLocales[value]!);
      context.read<RootBloc>().add(SetLocale());
    }
  }

  void _changeThemeSelection(String? value) {
    if (value != null) {
      context.read<RootBloc>().add(SetTheme(value));
    }
  }
}
