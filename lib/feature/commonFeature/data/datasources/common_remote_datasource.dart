import 'package:http/http.dart' as http;
import '../../../../infrastructure/network/network_client.dart';

class CommonRemoteDatasource {
  final NetworkClient networkClient;

  CommonRemoteDatasource({required this.networkClient});

  Future<String?> getStoreVersion(String packageName) async {
    try {
      final http.Response response = await http.get(Uri.parse(
          "https://play.google.com/store/apps/details?id=$packageName&gl=US"));
      if (response.statusCode == 200) {
        RegExp regexp =
        RegExp(r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]');
        String? version = regexp.firstMatch(response.body)?.group(1);
        return version;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}