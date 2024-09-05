import '../../../../infrastructure/network/network_client.dart';

class CommonRemoteDatasource {
  final NetworkClient networkClient;

  CommonRemoteDatasource({required this.networkClient});

  Future<String?> getStoreVersion(String packageName) async {
    final url = Uri.parse("https://play.google.com/store/apps/details?id=$packageName&gl=US");

    try {
      final responseString = await networkClient.getRequest(url, (dynamic responseBody) {
        return responseBody.toString(); // Directly return the response body as String
      });

      RegExp regexp = RegExp(r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]');
      String? version = regexp.firstMatch(responseString)?.group(1);
      return version;
    } catch (e) {
      print('Failed to fetch store version: $e');
      return null;
    }
  }
}