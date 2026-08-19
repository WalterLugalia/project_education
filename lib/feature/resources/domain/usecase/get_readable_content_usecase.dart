import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/domain/repositories/resource_repository.dart';

class GetReadableContentUseCase {
  final ResourceRepository repository;
  const GetReadableContentUseCase(this.repository);
  Future<String?> call(ResourceEntity resource) => repository.getReadableContent(resource);
}