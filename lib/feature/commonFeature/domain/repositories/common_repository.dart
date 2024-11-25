abstract class CommonRepository {
  Future<bool> checkUpdate();
  Future<void> openPlayStore();
  Future<String> getCurrentVersion();
  Future<bool> getTheme();
}