
import '../../../commonFeature/data/datasources/common_local_datasource.dart';

class SettingsLocalDatasource {
  final CommonLocalDatasource _commonLocalDatasource;

  SettingsLocalDatasource(this._commonLocalDatasource);

  Future<String> getNicknameFromSharedPreferences() async {
    final nickname = await _commonLocalDatasource.getDataFromSharedPreferences<String>('nickname');
    return nickname ?? 'D';
  }

  Future<void> setNicknameFromSharedPreferences(String nickname) async {
    await _commonLocalDatasource.setDataFromSharedPreferences('nickname', nickname);
  }

  Future<bool?> getThemeFromSharedPreferences() async {
    return _commonLocalDatasource.getThemeFromSharedPreferences();
  }

  Future<void> setThemeFromSharedPreferences(bool value) async {
    return _commonLocalDatasource.setDataFromSharedPreferences('isDarkTheme', value);
  }
}