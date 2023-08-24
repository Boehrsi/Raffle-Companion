import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../root/root.dart';
import '../root/root_cubit.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/files.dart';
import 'entry_list/entry_list_cubit.dart';
import 'info/info_cubit.dart';
import 'l10n/l10n.dart';
import 'settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupData();
  await prepareFiles();

  final cubit = RootCubit()..add(LoadRoot());
  cubit.stream.listen((event) {
    if (event is RootSuccess) {
      WindowOptions windowOptions = WindowOptions(
        minimumSize: kMinimumSize,
        size: cubit.size,
        center: true,
        title: kTextAppName,
        titleBarStyle: TitleBarStyle.hidden,
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      runApp(
        EasyLocalization(
          supportedLocales: kLocales.values.toList(),
          saveLocale: true,
          path: kLocalePath,
          useOnlyLangCode: true,
          fallbackLocale: kLocaleEnglish,
          child: RaffleCompanion(rootCubit: cubit),
        ),
      );
    }
  });
}

class RaffleCompanion extends StatelessWidget {
  final RootCubit rootCubit;

  const RaffleCompanion({required this.rootCubit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: rootCubit),
        BlocProvider(create: (BuildContext context) => EntryListCubit()),
        BlocProvider(create: (context) => SettingsCubit()..loadSettings(), lazy: false),
        BlocProvider(create: (context) => InfoCubit()),
      ],
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: FluentThemeData(
          accentColor: kPrimary,
          brightness: rootCubit.theme.value,
        ),
        home: const Root(),
      ),
    );
  }
}
