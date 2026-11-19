import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createUser({
    required String name,
    required String username,
    required String email,
  }) async {
    if (saving) return;
    saving = true;
    notifyListeners();

    try {
      final draft = User(
        id: 0,
        name: name,
        username: username,
        email: email,
        phone: '000-000-0000',
        website: null,
        address: const Address(
          street: 'Main St',
          suite: 'Apt. 1',
          city: 'Almaty',
          zipcode: '050000',
          geo: Geo(lat: 43.2389, lng: 76.8897),
        ),
        company: (name: 'New Company', catchPhrase: 'Created from Flutter app'),
      );
      final created = await _repo.create(draft);
      items = [created, ...items];
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
