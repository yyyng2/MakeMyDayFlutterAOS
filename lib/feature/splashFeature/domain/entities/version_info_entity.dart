class VersionInfoEntity {
  final String installedVersion;
  final String? storeVersion;

  VersionInfoEntity({required this.installedVersion, this.storeVersion});

  bool get isUpdateAvailable => storeVersion != null && storeVersion != installedVersion;
}