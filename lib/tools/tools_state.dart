abstract class ToolsState {}

class ToolsInitial extends ToolsState {}

class ToolsSuccess extends ToolsState {
  DateTime formattedNow;
  DateTime formattedFuture;

  ToolsSuccess({required this.formattedNow, required this.formattedFuture});
}
