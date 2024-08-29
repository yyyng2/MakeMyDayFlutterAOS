import '../repositories/splash_repository.dart';

class SplashUsecase {
  final SplashRepository repository;

  SplashUsecase({required this.repository});

  Future<bool?> call() async {
    return await repository.checkUpdate();
  }

  Future<void> openPlayStore() async {
    await repository.openPlayStore();
  }
}
