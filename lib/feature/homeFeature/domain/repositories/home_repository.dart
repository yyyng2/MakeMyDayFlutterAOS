abstract class HomeRepository {
  Future<String> getNickname();
  Future<Map<String, dynamic>> getProfileImage();
}