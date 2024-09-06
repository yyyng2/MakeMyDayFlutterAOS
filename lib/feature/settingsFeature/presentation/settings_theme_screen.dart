import 'package:flutter/material.dart';
import 'package:make_my_day/feature/mainTabFeature/presentation/bloc/main_tab_bloc.dart';
import 'bloc/settings_bloc.dart';

class SettingsThemeScreen extends StatefulWidget {
  final SettingsBloc settingsBloc;
  final bool isDarkTheme;
  final MainTabBloc mainTabBloc;

  const SettingsThemeScreen({
    super.key,
    required this.settingsBloc,
    required this.isDarkTheme,
    required this.mainTabBloc,
  });

  @override
  SettingsThemeScreenState createState() => SettingsThemeScreenState();
}

class SettingsThemeScreenState extends State<SettingsThemeScreen> {
  late bool selectedDarkTheme;

  @override
  void initState() {
    super.initState();
    selectedDarkTheme = widget.isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '테마를 변경해볼까요?',
            style: TextStyle(
              color: widget.isDarkTheme ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildThemeOption(
                isDarkTheme: widget.isDarkTheme,
                imagePath: 'assets/images/theme/theme_black.png',
                isSelected: selectedDarkTheme,
                onTap: () {
                  setState(() {
                    selectedDarkTheme = true;
                  });
                },
              ),
              _buildThemeOption(
                isDarkTheme: widget.isDarkTheme,
                imagePath: 'assets/images/theme/theme_color.png',
                isSelected: !selectedDarkTheme,
                onTap: () {
                  setState(() {
                    selectedDarkTheme = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                label: '취소',
                color: Colors.red,
                textColor: widget.isDarkTheme ? Colors.black : Colors.white,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: '확인',
                color: widget.isDarkTheme ? Colors.white : Colors.black,
                textColor: widget.isDarkTheme ? Colors.black : Colors.white,
                onTap: () {
                  if (selectedDarkTheme != widget.isDarkTheme) {
                    widget.settingsBloc.changeTheme(
                        selectedDarkTheme, widget.mainTabBloc);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required bool isDarkTheme,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(
            color: isDarkTheme ? Colors.white : Colors.cyan,
            width: 3,
          )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: isSelected ? 130 : 100,
                height: isSelected ? 250 : 220,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}