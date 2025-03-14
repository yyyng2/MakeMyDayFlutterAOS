import 'package:make_my_day/feature/settingsFeature/data/datasources/settings_local_datasource.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource datasource;

  SettingsRepositoryImpl({required this.datasource});

  @override
  Future<String> getNickname() async {
    return await datasource.getNicknameFromSharedPreferences();
  }

  @override
  Future<void> setNickname(String nickname) async {
    await datasource.setNicknameFromSharedPreferences(nickname);
  }

  @override
  Future<bool> getTheme() async {
    final result = await datasource.getThemeFromSharedPreferences() ?? false ;
    return result;
  }

  @override
  Future<void> setTheme(bool value) async {
    await datasource.setThemeFromSharedPreferences(value);
  }
}