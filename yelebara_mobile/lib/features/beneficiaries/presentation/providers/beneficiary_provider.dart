import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/beneficiary_local_datasource.dart';
import '../../data/repositories/beneficiary_repository_impl.dart';
import '../../domain/entities/beneficiary_entity.dart';
import '../../domain/repositories/beneficiary_repository.dart';
import '../../../../../features/auth/presentation/controllers/auth_provider.dart'; // For sharedPreferencesProvider if exported, or just use core

// We can look up sharedPreferencesProvider from main.dart or where we defined it. 
// Assuming sharedPreferencesProvider is in `lib/features/auth/presentation/controllers/auth_provider.dart` 
// (which we saw imported in main.dart:6) OR generally available. 
// Actually main.dart uses it. Let's assume we can redefine or import.
// To stay clean, let's assume we can get it via ref from main or we should have a core provider.
// However, `auth_provider.dart` was referenced in main.dart.
// Let's check `auth_provider.dart` later if missing. 
// For now, I'll rely on global override or import. 
// Actually `sharedPreferencesProvider` is likely in a core file or I'll just redefined a simple one here for now if not found easily?
// No, duplicates are bad. I saw `package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart` in main.dart.

final beneficiaryLocalDataSourceProvider = Provider<BeneficiaryLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BeneficiaryLocalDataSource(prefs);
});

final beneficiaryRepositoryProvider = Provider<BeneficiaryRepository>((ref) {
  final dataSource = ref.watch(beneficiaryLocalDataSourceProvider);
  return BeneficiaryRepositoryImpl(dataSource);
});

final beneficiaryProvider = FutureProvider<List<BeneficiaryEntity>>((ref) async {
  final repository = ref.watch(beneficiaryRepositoryProvider);
  return repository.getBeneficiaries();
});
