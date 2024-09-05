import 'package:flutter/material.dart';
import 'bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsAppInfoScreen extends StatefulWidget {
  final String currentVersion;
  final SettingsBloc settingsBloc;
  final bool existUpdate;

  const SettingsAppInfoScreen({
    super.key,
    required this.currentVersion,
    required this.settingsBloc,
    required this.existUpdate,
  });

  @override
  SettingsAppInfoScreenState createState() => SettingsAppInfoScreenState();
}

class SettingsAppInfoScreenState extends State<SettingsAppInfoScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> launchEmail() async {
    final email = 'yyyng2@gmail.com';
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      try {
        await launchUrl(url);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Row(
            children: [
              Icon(Icons.chevron_left),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // toolbarHeight: 0, // Hide AppBar, we set custom navigation
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dIcon/day_color.png',
              ),
              const Text("Make My Day"),
              // TextButton(
              //   onPressed: () async {
              //     const appURL = 'instagram://user?username=_yyyng';
              //     const webURL = 'https://instagram.com/_yyyng';
              //     if (await canLaunchUrl(Uri.parse(appURL))) {
              //       await launchUrl(Uri.parse(appURL));
              //     } else {
              //       await launchUrl(Uri.parse(webURL));
              //     }
              //   },
              //   child: const Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text("Developer: Dongyeong Kim"),
              //       Icon(Icons.link_rounded),
              //     ],
              //   ),
              // ),
              const Text("Developer: Dongyeong Kim"),
              const Text("Illustrator: Heejeong Chae"),
              TextButton(
                onPressed: () {
                  launchEmail();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Email: yyyng2@gmail.com"),
                    Icon(Icons.mail),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  const appURL = 'instagram://user?username=makemyday_app';
                  const webURL = 'https://instagram.com/makemyday_app';
                  if (await canLaunchUrl(Uri.parse(appURL))) {
                    await launchUrl(Uri.parse(appURL));
                  } else {
                    await launchUrl(Uri.parse(webURL));
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Insta: @makemyday_app"),
                    Icon(Icons.link_rounded),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (widget.existUpdate) {
                    widget.settingsBloc.add(GoToStoreEvent());
                  }
                },
                child: Column(
                  children: [
                    Text(widget.currentVersion),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}