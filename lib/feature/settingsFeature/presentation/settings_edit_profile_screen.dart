import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'bloc/settings_bloc.dart';

class SettingsEditProfileScreen extends StatefulWidget {
  final String? nickname;
  final SettingsBloc settingsBloc;

  const SettingsEditProfileScreen({super.key, required this.nickname, required this.settingsBloc});

  @override
  SettingsEditProfileScreenState createState() => SettingsEditProfileScreenState();
}

class SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final TextEditingController _nicknameController = TextEditingController();
  late String placeholderText = 'Enter your nickname';

  @override
  void initState() {
    super.initState();
    placeholderText = widget.nickname ?? 'D';
    _loadSavedImage();
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
        title: const Text('Profile Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _image != null
                      ? FileImage(_image!) // Use FileImage with the File type
                      : const AssetImage('assets/images/dicon/day_color.png')
                  as ImageProvider,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nicknameController,
                  maxLength: 7,
                  decoration: InputDecoration(
                    hintText: placeholderText,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Load Image'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
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
    if (_nicknameController.text.isNotEmpty) {
      final String nickname = _nicknameController.text;
      widget.settingsBloc.add(SetNickname(nickname));
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/custom_profile_image';
    final existingImage = File(path);

    if (_image != null) {
      await _image!.copy(path);
    } else {
      if (await existingImage.exists()) {
        await existingImage.delete();
      }
    }

    Navigator.pop(context);
  }

  void _resetProfile() {
    setState(() {
      _nicknameController.clear();
      _image = null;
    });
  }
}