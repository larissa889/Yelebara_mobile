import 'package:shared_preferences/shared_preferences.dart';

class HomeLocalDataSource {
  final SharedPreferences sharedPreferences;

  HomeLocalDataSource(this.sharedPreferences);

  Future<String> getUserName() async {
    return sharedPreferences.getString('current_user_name') ?? 'Client';
  }

  Future<bool> isFirstLaunch() async {
    return sharedPreferences.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    await sharedPreferences.setBool('is_first_launch', false);
  }
}
