import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final cityFilter = context.watch<SettingsModel>().city;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          unawaited(
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewUserScreen()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context, m, cityFilter),
    );
  }

  Widget _buildBody(BuildContext context, UsersModel m, String? cityFilter) {
    if (m.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibleItems = cityFilter == null
        ? m.items
        : m.items.where((u) => u.address.city == cityFilter).toList();

    return switch (m.error) {
      null => Column(
        children: [
          if (m.fromCache)
            Material(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Saved data · no connection')),
                    TextButton(
                      onPressed: () => unawaited(m.load()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: m.load,
              child: ListView.separated(
                itemCount: visibleItems.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = visibleItems[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('${user.email} · ${user.address.city}'),
                    onTap: () {
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailScreen(user: user),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      NoConnectionException() => _OfflineView(
        icon: Icons.wifi_off,
        message: 'No internet connection',
        onRetry: () => unawaited(m.load()),
      ),
      NotFoundException() || UnauthorizedException() => _OfflineView(
        icon: Icons.lock_outline,
        message: 'Request rejected by server',
        onRetry: () => unawaited(m.load()),
      ),
      ServerException(:final status) => _OfflineView(
        icon: Icons.cloud_off,
        message: 'Server error ($status)',
        onRetry: () => unawaited(m.load()),
      ),
      BadResponseException(:final detail) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Bad response: ${detail ?? 'invalid JSON'}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    };
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
