abstract class CommonRepository {
  Future<bool> checkUpdate();
  Future<void> openPlayStore();
  Future<bool> getTheme();
}