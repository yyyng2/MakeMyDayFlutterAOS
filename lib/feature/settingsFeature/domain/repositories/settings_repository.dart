abstract class SettingsRepository {
  Future<String> getNickname();
  Future<void> setNickname(String nickname);
  Future<bool> getTheme();
  Future<void> setTheme(bool value);
}