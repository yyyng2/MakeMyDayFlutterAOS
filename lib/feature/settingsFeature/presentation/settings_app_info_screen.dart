import 'package:flutter/material.dart';
import 'bloc/settings_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsAppInfoScreen extends StatefulWidget {
  final String currentVersion;
  final SettingsBloc settingsBloc;
  final bool existUpdate;
  final bool isDarkTheme;

  const SettingsAppInfoScreen({
    super.key,
    required this.currentVersion,
    required this.settingsBloc,
    required this.existUpdate,
    required this.isDarkTheme,
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
    const email = 'yyyng2@gmail.com';
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': '[MMDApp] 문의',
        'body': '내용을 입력해주세요.',
      },
    );

    print('Launching email with URI: $emailUri');

    if (await canLaunchUrl(emailUri)) {
      try {
        await launchUrl(emailUri);
      } catch (e) {
        print('Error launching email: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Email App Found'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please copy the email address below and open your email client manually:'),
                const SizedBox(height: 10),
                SelectableText(email), // Allow user to copy the email
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Email App Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please copy the email address below and open your email client manually:'),
              const SizedBox(height: 10),
              SelectableText(email), // Allow user to copy the email
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDarkTheme ? Colors.black87 : Colors.white,
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
        // toolbarHeight: 0, // Hide AppBar, we set custom navigation
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.isDarkTheme ? 'assets/images/dIcon/day_white.png' : 'assets/images/dIcon/day_color.png',
              ),
              Text(
                "Make My Day",
                style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
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
              Text(
                  "Developer: Dongyeong Kim",
                style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
              Text(
                  "Illustrator: Heejeong Chae",
                style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
              TextButton(
                onPressed: () {
                  launchEmail();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Email: yyyng2@gmail.com",
                      style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                    ),
                    Icon(
                      Icons.mail,
                    color: widget.isDarkTheme ? Colors.white : Colors.black,
                    ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Insta: @makemyday_app",
                      style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                    ),
                    Icon(
                        Icons.link_rounded,
                      color: widget.isDarkTheme ? Colors.white : Colors.black,
                    ),
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
                    Text(
                      widget.currentVersion,
                      style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                    ),
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