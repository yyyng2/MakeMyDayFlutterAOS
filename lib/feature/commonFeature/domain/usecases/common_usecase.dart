import '../repositories/common_repository.dart';

class CommonUsecase {
  final CommonRepository repository;

  CommonUsecase({required this.repository});

  Future<bool?> checkUpdate() async {
    return await repository.checkUpdate();
  }

  Future<void> openPlayStore() async {
    await repository.openPlayStore();
  }

  Future<String> getCurrentVersion() async {
    return await repository.getCurrentVersion();
  }

  Future<bool> getTheme() async {
    return await repository.getTheme();
  }
}
