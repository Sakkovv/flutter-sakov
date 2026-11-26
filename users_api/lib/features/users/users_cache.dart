import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    final encoded = jsonEncode([for (final u in list) u.toJson()]);
    await file.writeAsString(encoded);
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    return [
      for (final item in decoded) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
