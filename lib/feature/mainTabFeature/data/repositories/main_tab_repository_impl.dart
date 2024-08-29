import '../../domain/repositories/main_tab_repository.dart';
import '../datasources/main_tab_local_datasource.dart';

class MainTabRepositoryImpl implements MainTabRepository {
  final MainTabLocalDatasource datasource;

  MainTabRepositoryImpl({required this.datasource});

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