import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../entry_list/entry_list.dart';
import '../info/info.dart';
import '../root/root_cubit.dart';
import '../settings/mail_preset_settings.dart';
import '../settings/platform_settings.dart';
import '../utils/l10n.dart';
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
    await windowManager.getSize().then((size) => context.read<RootCubit>().add(PersistRoot(size)));
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: AppBarTitle(text: kTextAppName),
        actions: AppBarActions(),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _pageIndex,
        onChanged: (page) => setState(() => _pageIndex = page),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.list),
            title: const Text(kTextEntries),
            body: const EntryList(showUsed: false),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.check_mark),
            title: const Text(kTextEntriesUsed),
            body: const EntryList(showUsed: true),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text(kTextPlatformSettings),
            body: const PlatformSettings(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.mail_options),
            title: const Text(kTextMailPresetSettings),
            body: const MailPresetSettings(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.info),
            title: const Text(kTextInfoTitle),
            body: const Info(),
          ),
        ],
      ),
    );
  }
}
