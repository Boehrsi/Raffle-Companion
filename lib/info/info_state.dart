abstract class InfoState {}

class InfoInitial extends InfoState {}

class InfoSuccess extends InfoState {
  final Uri filesPath;
  final String log;
  final String version;

  InfoSuccess({
    required this.filesPath,
    required this.log,
    required this.version,
  });
}
