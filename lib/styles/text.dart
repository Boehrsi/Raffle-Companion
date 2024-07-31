import 'package:fluent_ui/fluent_ui.dart';

extension TextStyles on BuildContext {
  TextStyle? get textStyleTitle => _of().typography.title;

  TextStyle? get textStyleSubtitle => _of().typography.subtitle;

  TextStyle? get textStyleBody => _of().typography.body;

  FluentThemeData _of() => FluentTheme.of(this);
}
