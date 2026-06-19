import 'package:isar/isar.dart';

part 'local_analytics_model.g.dart';

@collection
class LocalAnalyticsModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String eventName;

  late DateTime timestamp;

  @ignore
  Map<String, String> properties = {};

  LocalAnalyticsModel({
    required this.eventName,
    required this.timestamp,
  });
}
