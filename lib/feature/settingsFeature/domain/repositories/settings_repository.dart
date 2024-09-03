abstract class SettingsRepository {
  Future<String> getNickname();
  Future<void> setNickname(String nickname);
}