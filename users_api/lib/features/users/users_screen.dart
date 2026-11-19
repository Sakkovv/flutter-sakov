import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
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
      body: _buildBody(context, m),
    );
  }

  Widget _buildBody(BuildContext context, UsersModel m) {
    if (m.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return switch (m.error) {
      null => RefreshIndicator(
        onRefresh: m.load,
        child: ListView.separated(
          itemCount: m.items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = m.items[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text('${user.email} • ${user.address.city}'),
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
