import 'package:flutter/material.dart';

import '../../commonFeature/presentation/navigation/app_router.dart';
import 'enums/settings_options.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background/background.png',
            fit: BoxFit.cover,
          ),
        ),
        ListView.builder(
          itemCount: SettingsOptions.values.length,
          itemBuilder: (context, index) {
            final option = SettingsOptions.values[index];
            return Material(
                color: Colors.transparent,
                child: Padding(
                padding: const EdgeInsets.all(8.0),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(option.name.toString()),
              onTap: () {
                // Handle tap based on the selected option
                switch (option) {
                  case SettingsOptions.appInfo:
                    Navigator.pushNamed(
                      context,
                      AppRouter.appInfo,
                      arguments: {
                        'currentVersion': '1.0.0',
                        'currentAppstoreVersion': '1.0.0',
                      },
                    );
                  case SettingsOptions.editProfile:
                    Navigator.pushNamed(context, AppRouter.editProfile);
                  case SettingsOptions.theme:
                  // Navigate to Theme Settings
                    break;
                  case SettingsOptions.openSources:
                  // Navigate to Open Source Licenses
                    break;
                }
              },
            ),));
          },
        ),
      ]),

    );
  }
}
