import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/root/root_cubit.dart';
import 'package:window_manager/window_manager.dart';

import '../styles/text.dart';

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

class AppBarTitle extends StatelessWidget {
  final String text;

  const AppBarTitle({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: context.titleLargeStyle,
        ),
      ),
    );
  }
}

class AppBarActions extends StatelessWidget {
  const AppBarActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: context.watch<RootCubit>().theme.value,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class LayoutSpacer extends StatelessWidget {
  const LayoutSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container());
  }
}
