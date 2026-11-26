import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatarPath = await prefs.getString('avatarPath');

  const secureStore = SecureStore();
  final initialToken = await secureStore.readToken();

  final api = ApiClient(http.Client(), secureStore);
  final repo = UserRepository(api, UsersCache());

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStore>.value(value: secureStore),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city,
            avatarPath: avatarPath,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthModel(secureStore, initialToken: initialToken),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(repo);
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsModel>().dark;
    final isSignedIn = context.watch<AuthModel>().signedIn;

    return MaterialApp(
      title: 'Users',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: isSignedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
