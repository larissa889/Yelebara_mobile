import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/beneficiary_entity.dart';

class BeneficiaryLocalDataSource {
  final SharedPreferences _prefs;

  BeneficiaryLocalDataSource(this._prefs);

  Future<List<BeneficiaryEntity>> getBeneficiaries() async {
    final index = _prefs.getStringList('beneficiaries_index') ?? <String>[];
    final List<BeneficiaryEntity> beneficiaries = [];

    for (final email in index) {
      final name = _prefs.getString('profile:' + email + ':name') ?? '';
      final phone = _prefs.getString('profile:' + email + ':phone') ?? '';
      final addr = _prefs.getString('profile:' + email + ':address1') ?? '';
      
      beneficiaries.add(
        BeneficiaryEntity(
          name: name,
          email: email,
          phone: phone,
          quartier: addr,
        ),
      );
    }
    return beneficiaries;
  }
}
