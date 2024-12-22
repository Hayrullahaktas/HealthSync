

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/storage_provider.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: Consumer<StorageProvider>(
        builder: (context, storageProvider, child) {
          return Column(
            children: [
              ListTile(
                title: Text('Name: ${storageProvider.userName ?? "Not set"}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    // Update name logic
                    await storageProvider.saveUserProfile(
                      name: 'New Name',
                      height: storageProvider.userHeight ?? 170,
                      weight: storageProvider.userWeight ?? 70,
                      age: storageProvider.userAge ?? 25,
                    );
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: storageProvider.isDarkMode,
                onChanged: (_) => storageProvider.toggleThemeMode(),
              ),
            ],
          );
        },
      ),
    );
  }
}