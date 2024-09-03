import '../../domain/repositories/settings_repository.dart';

class SettingsUsecase {
  final SettingsRepository settingsRepository;

  SettingsUsecase({
    required this.settingsRepository,
  });

  Future<String> fetchNickname() async {
    return await settingsRepository.getNickname();
  }

  Future<void> setNickname(String nickname) async {
    await settingsRepository.setNickname(nickname);
  }
}