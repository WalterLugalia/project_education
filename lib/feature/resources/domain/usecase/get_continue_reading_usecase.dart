import '../entities/continue_reading_item.dart';
import '../repositories/resource_repository.dart';

class GetContinueReadingUseCase {
  final ResourceRepository repository;
  const GetContinueReadingUseCase(this.repository);
  Future<List<ContinueReadingItem>> call() => repository.getContinueReading();
}