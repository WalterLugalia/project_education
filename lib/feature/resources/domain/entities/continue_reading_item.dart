import 'resource_entity.dart';

class ContinueReadingItem {
  final ResourceEntity resource;
  final double progressPercent;

  const ContinueReadingItem({
    required this.resource,
    required this.progressPercent,
  });
}