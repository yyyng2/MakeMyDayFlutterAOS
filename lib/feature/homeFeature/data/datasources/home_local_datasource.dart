import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../../../commonFeature/data/datasources/common_local_datasource.dart';

class HomeLocalDatasource {
  final CommonLocalDatasource _commonLocalDatasource;

  HomeLocalDatasource(this._commonLocalDatasource);

  Future<String> getNicknameFromSharedPreferences() async {
    final nickname = await _commonLocalDatasource.getDataFromSharedPreferences<String>('nickname');
    return nickname ?? 'D';
  }

  Future<bool?> getThemeFromSharedPreferences() async {
    return _commonLocalDatasource.getDataFromSharedPreferences<bool>('isDarkTheme');
  }

  Future<Map<String, dynamic>> loadSavedProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/custom_profile_image';
    final savedImage = File(path);

    if (await savedImage.exists()) {
      return {'isFile': true, 'image': savedImage};
    } else {
      String defaultImagePath;
      final isDarkTheme = await getThemeFromSharedPreferences() ?? false;

      if (isDarkTheme) {
        defaultImagePath = 'assets/images/dIcon/day_white.png';
      } else {
        defaultImagePath = 'assets/images/dIcon/day_color.png';
      }

      return {'isFile': false, 'image': defaultImagePath};
    }
  }
}