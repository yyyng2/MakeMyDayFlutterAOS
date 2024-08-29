import '../repositories/main_tab_repository.dart';

class MainTabUsecase {
  final MainTabRepository repository;

  MainTabUsecase({required this.repository});

  Future<bool?> call() async {
    return await repository.getTheme();
  }

  Future<void> setTheme(bool value) async {
    await repository.setTheme(value);
  }
}