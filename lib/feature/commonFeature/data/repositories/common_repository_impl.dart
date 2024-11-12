import 'package:url_launcher/url_launcher.dart';

import '../datasources/common_local_datasource.dart';
import '../datasources/common_remote_datasource.dart';
import '../../domain/entities/version_info_entity.dart';
import '../../domain/repositories/common_repository.dart';

class CommonRepositoryImpl implements CommonRepository {
  final CommonLocalDatasource localDatasource;
  final CommonRemoteDatasource? remoteDatasource;

  CommonRepositoryImpl({required this.localDatasource, required this.remoteDatasource});

  @override
  Future<bool> checkUpdate() async {
    try {
      final installedVersion = await localDatasource.getCurrentAppVersion();
      final packageName = await localDatasource.getCurrentAppPackageName();
      final storeVersion = await remoteDatasource?.getStoreVersion(packageName);
      print("installedVersion: ${installedVersion}, storeVersion: $storeVersion");
      return VersionInfoEntity(installedVersion: installedVersion, storeVersion: storeVersion).isUpdateAvailable;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<void> openPlayStore() async {
    final packageName = await localDatasource.getCurrentAppPackageName();
    final Uri uri = Uri.parse("market://details?id=$packageName");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not launch $uri";
    }
  }

  @override
  Future<bool> getTheme() async {
    final result = await localDatasource.getThemeFromSharedPreferences() ?? false ;
    return result;
  }
}