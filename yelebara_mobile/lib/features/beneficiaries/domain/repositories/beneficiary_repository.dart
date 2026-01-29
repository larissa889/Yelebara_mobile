import '../entities/beneficiary_entity.dart';

abstract class BeneficiaryRepository {
  Future<List<BeneficiaryEntity>> getBeneficiaries();
}
