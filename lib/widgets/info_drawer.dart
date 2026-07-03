import 'package:flutter/material.dart';
import '../constants.dart';
import 'app_logo.dart';

/// A side drawer that provides information about the application,
/// algorithms used, and usage instructions.
class AppInfoDrawer extends StatelessWidget {
  const AppInfoDrawer({super.key});

  /// The main descriptive text for the About section.
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
    final theme = Theme.of(context);
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      informationBody,
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const Divider(height: 32),
                    Text(
                      'UNDERSTANDING ENTROPY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _EntropyGuideItem(
                      label: 'WEAK (< 64 bits)',
                      description: 'Can be cracked in seconds or minutes by modern GPUs.',
                      color: Colors.red,
                    ),
                    const _EntropyGuideItem(
                      label: 'FAIR (64-80 bits)',
                      description: 'Resistant to casual attacks, but vulnerable to dedicated hardware.',
                      color: Colors.orange,
                    ),
                    const _EntropyGuideItem(
                      label: 'GOOD (80-112 bits)',
                      description: 'Secure against almost all current computing power.',
                      color: Colors.lightGreen,
                    ),
                    const _EntropyGuideItem(
                      label: 'EXCELLENT (> 112 bits)',
                      description: 'Industry standard for high-security master keys.',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tip: Use Argon2id with a Salt to significantly increase "Work Factor", making your password even harder to crack!',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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

class _EntropyGuideItem extends StatelessWidget {
  final String label;
  final String description;
  final Color color;

  const _EntropyGuideItem({
    required this.label,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 2),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}
