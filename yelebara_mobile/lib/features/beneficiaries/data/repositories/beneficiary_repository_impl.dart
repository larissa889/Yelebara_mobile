import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../datasources/beneficiary_local_datasource.dart';

class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryLocalDataSource _dataSource;

  BeneficiaryRepositoryImpl(this._dataSource);

  @override
  Future<List<BeneficiaryEntity>> getBeneficiaries() =>
      _dataSource.getBeneficiaries();
}
