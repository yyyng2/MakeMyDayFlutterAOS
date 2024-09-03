import '../../../commonFeature/data/datasources/common_local_datasource.dart';

class MainTabLocalDatasource {
  final CommonLocalDatasource _commonLocalDatasource;

  MainTabLocalDatasource(this._commonLocalDatasource);

  Future<bool?> getIsFirstFromSharedPreferences() async {
    return _commonLocalDatasource.getDataFromSharedPreferences<bool>('isLaunchFirst');
  }

  Future<void> setIsFirstFromSharedPreferences(bool isFisrt) async {
    _commonLocalDatasource.setDataFromSharedPreferences('isLaunchFirst', isFisrt);
  }

  Future<bool?> getThemeFromSharedPreferences() async {
    return _commonLocalDatasource.getDataFromSharedPreferences<bool>('isDarkTheme');
  }

  Future<void> setThemeFromSharedPreferences(bool value) async {
    return _commonLocalDatasource.setDataFromSharedPreferences('isDarkTheme', value);
  }
}