// lib/feature/resources/domain/usecase/get_new_releases_usecase.dart
import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetNewReleasesUseCase {
  final ResourceRepository repository;
  const GetNewReleasesUseCase(this.repository);
  Future<List<ResourceEntity>> call({String? type}) => repository.getNewReleases(type: type);
}