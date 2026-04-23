import 'package:flutter/material.dart';
import '../constants.dart';
import 'app_logo.dart';

class AppInfoDrawer extends StatelessWidget {
  const AppInfoDrawer({super.key});

  // This text is now in its own dedicated method/file area, 
  // making it much easier to find and update.
  static const String informationBody = '''
PHAT (Password Hashing Algorithm Tool)
${AppConstants.copyright}
Version ${AppConstants.version}

The purpose of this tool is to let an individual enter text and have a hashed output to use as the password to a site or program. 

Available Algorithms:
- SHA-256, 384, 512 (Standard)
- Argon2id, PBKDF2 (Advanced/Secure)

Note: Advanced algorithms require a "Salt" (e.g., the website name or your email) to work correctly and provide maximum security.

The number of digits in the output is selectable in case a site can only have a certain number of digits in a password. 

This program comes with ABSOLUTELY NO WARRANTY; This is free software, and you are welcome to redistribute it under certain conditions. See https://www.gnu.org/licenses/ for more details. 

''';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppLogo(size: 80),
            const SizedBox(height: 16),
            const Text(
              AppConstants.appTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  informationBody,
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
