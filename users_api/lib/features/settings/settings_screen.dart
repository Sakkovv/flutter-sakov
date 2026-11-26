import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;

    final cities = users.map((u) => u.address.city).toSet().toList()..sort();
    final selectedCity = cities.contains(settings.city) ? settings.city : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) => settings.setDark(value),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: selectedCity,
              decoration: const InputDecoration(
                labelText: 'Filter by city',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities'),
                ),
                for (final city in cities)
                  DropdownMenuItem<String?>(value: city, child: Text(city)),
              ],
              onChanged: (value) => settings.setCity(value),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign out'),
            onTap: () async {
              await context.read<AuthModel>().logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}
