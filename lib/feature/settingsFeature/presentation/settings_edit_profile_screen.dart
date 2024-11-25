import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/settings_bloc.dart';

class SettingsEditProfileScreen extends StatefulWidget {
  final String? nickname;
  final SettingsBloc settingsBloc;
  final bool isDarkTheme;

  const SettingsEditProfileScreen({
    super.key,
    required this.nickname,
    required this.settingsBloc,
    required this.isDarkTheme,
  });

  @override
  SettingsEditProfileScreenState createState() => SettingsEditProfileScreenState();
}

class SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final TextEditingController _nicknameController = TextEditingController();
  late String placeholderText = 'editProfileNamePlaceHolder'.tr();

  @override
  void initState() {
    super.initState();
    placeholderText = widget.nickname ?? 'D';
    _loadSavedImage();
  }

  @override
  void dispose() {
    _image = null;
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/custom_profile_image';
    final savedImage = File(path);

    if (await savedImage.exists()) {
      setState(() {
        _image = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
        title: Text('settingsMenuSettingsProfile'.tr(),
          style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Row(
            children: [
              Icon(
                Icons.chevron_left,
                color: widget.isDarkTheme ? Colors.white : Colors.black,
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
                Icons.save,
            color: widget.isDarkTheme ? Colors.white : Colors.black,),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
                widget.isDarkTheme
                    ? 'assets/images/background/background_black.png'
                    : 'assets/images/background/background.png',
                fit: BoxFit.cover,
              )
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: _image != null
                      ? ClipOval(
                    child: Image.file(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    widget.isDarkTheme
                        ? 'assets/images/dIcon/day_white.png'
                        : 'assets/images/dIcon/day_color.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  controller: _nicknameController,
                  maxLength: 7,
                  decoration: InputDecoration(
                    hintText: placeholderText,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10
                    ),
                  ),
                ),
            ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetProfile,
                      icon: const Icon(Icons.refresh, color: Colors.red,),
                      label: const Text(
                        "editProfileImageReset",
                        style: TextStyle(color: Colors.red),).tr(),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loadImage,
                      icon: const Icon(Icons.image),
                      label: const Text("editProfileImageLoad").tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      // 1. 먼저 닉네임 저장
      if (_nicknameController.text.isNotEmpty) {
        final String nickname = _nicknameController.text;
        widget.settingsBloc.add(SetNickname(nickname));
      }
      print("processing:1");
      // 2. 이미지 처리
      if (_image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/custom_profile_image';

        // 2.1 기존 파일 삭제 전에 존재 여부 확인
        final existingFile = File(path);
        if (await existingFile.exists()) {
          await existingFile.delete();
        }
        print("processing:2");

        // 2.2 새 이미지 복사 전에 원본 파일 존재 여부 확인
        if (await _image!.exists()) {
          // 2.3 복사 작업을 try-catch로 감싸기
          try {
            await _image!.copy(path);
            print("processing:2.5");
          } catch (e) {
            debugPrint('Image copy failed: $e');
            // 에러 발생시 이미지 저장 실패 메시지만 표시하고 계속 진행
          }
        }

        print("processing:3");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/custom_profile_image';

        final existingFile = File(path);
        if (await existingFile.exists()) {
          await existingFile.delete();
        }
      }

      // 3. 모든 작업이 완료된 후에만 UI 업데이트
      if (mounted) {
        // 3.1 상태 업데이트 전에 약간의 지연 추가
        await Future.delayed(const Duration(milliseconds: 100));
        print("processing:4");
        setState(() {});
        print("processing:5");
        Navigator.of(context).pop();
        print("processing:6");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('editProfileSaveError'.tr())),
        );
      }
    }
  }

  void _resetProfile() {
    setState(() {
      _nicknameController.text = "D";
      _image = null;
    });
  }
}