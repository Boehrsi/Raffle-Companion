import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raffle_companion/tools/tools_state.dart';

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit() : super(ToolsInitial());

  Future<void> loadTools({
    int? day,
    int? week,
    int? month,
    int? hours,
    int? minutes,
  }) async {
    final now = DateTime.now();

    final dateHours = hours ?? now.hour;
    final dateMinutes = minutes ?? now.minute;

    final dateFutureDay = now.day + (day ?? 0) + 7 * (week ?? 0);
    final dateFutureMonth = now.month + (month ?? 0);

    final dateNow = DateTime(
      now.year,
      now.month,
      now.day,
      dateHours,
      dateMinutes,
    );
    final dateFuture = DateTime(
      now.year,
      dateFutureMonth,
      dateFutureDay,
      dateHours,
      dateMinutes,
    );
    emit(ToolsSuccess(formattedNow: dateNow, formattedFuture: dateFuture));
  }
}
