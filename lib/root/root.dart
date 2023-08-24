import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/l10n/locale_keys.g.dart';
import 'package:window_manager/window_manager.dart';

import '../entry_list/entry_list.dart';
import '../info/info.dart';
import '../l10n/l10n.dart';
import '../root/root_cubit.dart';
import '../settings/mail_preset_settings.dart';
import '../settings/platform_settings.dart';
import '../settings/ui_settings.dart';
import '../widgets/layout.dart';
import 'navigation.dart';

class Root extends StatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> with WindowListener {
  int _pageIndex = NavigationPage.entries.key;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() async {
    await windowManager.getSize().then((size) => context.read<RootCubit>().add(SetSize(size)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootCubit, RootState>(
      builder: (context, state) {
        return NavigationView(
          appBar: const NavigationAppBar(
            title: AppBarTitle(text: kTextAppName),
            actions: AppBarActions(),
            automaticallyImplyLeading: false,
          ),
          pane: NavigationPane(selected: _pageIndex, onChanged: (page) => setState(() => _pageIndex = page), items: [
            PaneItemHeader(header: Text(LocaleKeys.entries.tr())),
            PaneItem(
              icon: const Icon(FluentIcons.list),
              title: Text(LocaleKeys.available.tr()),
              body: const EntryList(showUsed: false),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.check_mark),
              title: Text(LocaleKeys.used.tr()),
              body: const EntryList(showUsed: true),
            ),
            PaneItemSeparator(),
            PaneItemHeader(header: Text(LocaleKeys.settings.tr())),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(LocaleKeys.platforms.tr()),
              body: const PlatformSettings(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.mail_options),
              title: Text(LocaleKeys.mailPresets.tr()),
              body: const MailPresetSettings(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.content_settings),
              title: Text(LocaleKeys.ui.tr()),
              body: const UiSettings(),
            ),
          ], footerItems: [
            PaneItemSeparator(),
            PaneItem(
              icon: const Icon(FluentIcons.info),
              title: Text(LocaleKeys.infoTitle.tr()),
              body: const Info(),
            ),
          ]),
        );
      },
    );
  }
}
