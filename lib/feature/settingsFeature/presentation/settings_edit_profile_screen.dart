import 'dart:io';

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
        backgroundColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
        title: Text('Profile Settings',
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
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage(widget.isDarkTheme ? 'assets/images/dIcon/day_white.png' : 'assets/images/dIcon/day_color.png')
                  as ImageProvider,
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
                      icon: Icon(Icons.refresh, color: Colors.red,),
                      label: Text(
                        'Reset',
                        style: TextStyle(color: Colors.red),),
                    ),
                    ElevatedButton.icon(
                      onPressed: _loadImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Load Image'),
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