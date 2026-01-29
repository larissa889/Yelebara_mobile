import 'package:yelebara_mobile/features/home/domain/entities/home_info.dart';

abstract class HomeRepository {
  Future<HomeInfo> getHomeInfo();
  Future<void> setFirstLaunchDone();
  Stream<bool> getGpsStatusStream();
  Future<bool> checkGpsEnabled();
}
