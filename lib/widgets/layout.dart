import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/root/root_bloc.dart';
import 'package:raffle_companion/styles/text.dart';
import 'package:window_manager/window_manager.dart';

class ConstraintWidthContainer extends StatelessWidget {
  final Widget child;

  const ConstraintWidthContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1024),
      child: child,
    );
  }
}

class AppBar extends StatelessWidget {
  final String text;
  final bool showBack;

  const AppBar({
    required this.text,
    this.showBack = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showBack)
          PaneBackButton(
            enabled: true,
            onPressed: () => Navigator.pop(context),
          ),
        Expanded(
          child: DragToMoveArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(text, style: context.textStyleSubtitle),
            ),
          ),
        ),
        _AppBarActions()
      ],
    );
  }
}

class LayoutSpacer extends StatelessWidget {
  const LayoutSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(),
    );
  }
}

class _AppBarActions extends StatelessWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: context.watch<RootBloc>().theme.value,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
