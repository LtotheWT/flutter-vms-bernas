import '../entities/visitor_lookup_entity.dart';

abstract class VisitorAccessRepository {
  Future<VisitorLookupEntity> getVisitorLookup({
    required String code,
    required bool isCheckIn,
  });
}
