
import '../datasources/home_local_datasource.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource datasource;

  HomeRepositoryImpl({required this.datasource});

  @override
  Future<String> getNickname() async {
    final result = await datasource.getNicknameFromSharedPreferences();
    return result;
  }

  @override
  Future<Map<String, dynamic>> getProfileImage(bool isDarkTheme) async {
    return await datasource.loadSavedProfileImage(isDarkTheme);
  }
}