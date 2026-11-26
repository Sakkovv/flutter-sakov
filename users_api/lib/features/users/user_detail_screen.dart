import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Username'),
            subtitle: Text('@${user.username}'),
          ),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user.email),
            trailing: const Icon(Icons.email_outlined),
            onTap: () =>
                _openExternal(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text('${user.phone} (digits: ${user.phoneDigits})'),
            trailing: const Icon(Icons.phone_outlined),
            onTap: () => _openExternal(
              context,
              Uri(scheme: 'tel', path: user.phoneDigits),
            ),
          ),
          if (user.website case final website?)
            ListTile(
              title: const Text('Website'),
              subtitle: Text(website),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  _openExternal(context, Uri.parse('https://$website')),
            ),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${user.address.street}, ${user.address.suite}, '
              '${user.address.city} (${user.address.zipcode})\n'
              'Geo: ${user.address.geo.lat}, ${user.address.geo.lng}',
            ),
          ),
          ListTile(
            title: const Text('Company'),
            subtitle: Text(
              '${user.company.name}\n"${user.company.catchPhrase}"',
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.key),
              label: const Text('Copy token to clipboard'),
              onPressed: () async {
                final token = await context.read<SecureStore>().readToken();
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        token != null ? 'Token copied' : 'No token stored',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
