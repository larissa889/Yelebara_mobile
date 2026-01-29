import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/home/data/datasources/home_local_datasource.dart';
import 'package:yelebara_mobile/features/home/data/repositories/home_repository_impl.dart';
import 'package:yelebara_mobile/features/home/domain/repositories/home_repository.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';

part 'home_provider.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isFirstLaunch,
    @Default('') String userName,
    @Default('') String greeting,
    @Default(false) bool isGpsEnabled,
  }) = _HomeState;
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository repository;

  HomeNotifier(this.repository) : super(const HomeState()) {
    _init();
  }

  Future<void> _init() async {
    final info = await repository.getHomeInfo();
    
    final hour = DateTime.now().hour;
    final greeting = (hour >= 18 || hour < 5) ? 'Bonsoir' : 'Bonjour';

    state = state.copyWith(
      userName: info.userName,
      isFirstLaunch: info.isFirstLaunch,
      isGpsEnabled: info.isGpsEnabled,
      greeting: greeting,
    );

    if (info.isFirstLaunch) {
      await repository.setFirstLaunchDone();
    }

    _listenGpsServiceStatus();
  }

  void _listenGpsServiceStatus() {
    repository.getGpsStatusStream().listen((isEnabled) {
      state = state.copyWith(isGpsEnabled: isEnabled);
    });
  }
}

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HomeLocalDataSource(prefs);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final localDataSource = ref.watch(homeLocalDataSourceProvider);
  return HomeRepositoryImpl(localDataSource);
});

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});
