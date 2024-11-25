import 'dart:math' as math;

class VersionInfoEntity {
  final String installedVersion;
  final String? storeVersion;

  VersionInfoEntity({required this.installedVersion, this.storeVersion});

  bool get isUpdateAvailable {
    if (storeVersion == null) return false;

    // 버전 문자열을 숫자 배열로 변환
    List<int> installed = _parseVersionToNumbers(installedVersion);
    List<int> store = _parseVersionToNumbers(storeVersion!);

    // 더 짧은 배열의 길이만큼 반복
    int minLength = math.min(installed.length, store.length);

    // 각 자리수를 순차적으로 비교
    for (int i = 0; i < minLength; i++) {
      if (installed[i] < store[i]) {
        return true;  // 업데이트 필요
      } else if (installed[i] > store[i]) {
        return false; // 업데이트 불필요
      }
      // 같은 경우 다음 자리수 비교
    }

    // 모든 자리수가 같은 경우, 스토어 버전의 길이가 더 길면 업데이트 필요
    return store.length > installed.length;
  }

  List<int> _parseVersionToNumbers(String version) {
    // 버전 문자열을 . 기준으로 분리하고 각각을 정수로 변환
    return version
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}