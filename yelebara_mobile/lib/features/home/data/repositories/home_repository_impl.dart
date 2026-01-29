import 'package:geolocator/geolocator.dart';
import 'package:yelebara_mobile/features/home/data/datasources/home_local_datasource.dart';
import 'package:yelebara_mobile/features/home/domain/entities/home_info.dart';
import 'package:yelebara_mobile/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl(this.localDataSource);

  @override
  Future<HomeInfo> getHomeInfo() async {
    final name = await localDataSource.getUserName();
    final isFirst = await localDataSource.isFirstLaunch();
    final isGps = await Geolocator.isLocationServiceEnabled();

    return HomeInfo(
      userName: name,
      isFirstLaunch: isFirst,
      isGpsEnabled: isGps,
    );
  }

  @override
  Future<void> setFirstLaunchDone() async {
    await localDataSource.setFirstLaunchDone();
  }

  @override
  Future<bool> checkGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Stream<bool> getGpsStatusStream() {
    return Geolocator.getServiceStatusStream().map(
      (status) => status == ServiceStatus.enabled,
    );
  }
}
