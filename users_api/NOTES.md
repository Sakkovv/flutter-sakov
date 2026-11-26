# Mobile DevelopmentPractice 11: A Real Server


## Level 1: Postman / curl inspection
**GET `/users` и `/users/1`:** Статус `200 OK`, `Content-Type: application/json; charset=utf-8`. Всего сервер возвращает 10 пользователей.
**Вложенные объекты:** `address` и `company` (вложенные объекты 1-го уровня), `address.geo` (вложенный объект 2-го уровня).
**Nullable / опциональные поля:** По условию задачи единственное поле, которое модель трактует как опциональное (`String?`), — `website`.
**GET `/users/999`:** Статус `404 Not Found`, тело ответа — пустой JSON-объект `{}`.
**POST `/users`:** Статус `201 Created`, заголовок `location: https://jsonplaceholder.typicode.com/users/11`. Сервер возвращает отправленный JSON и добавляет `"id": 11`.
- **GET `/users?id=3`:** Возвращает JSON-массив из одного элемента `[{...}]` (`List`), а не одиночный объект.

### User (top-level)
| field | JSON type | Dart type | nullable? |
| :--- | :--- | :--- | :--- |
| id | number | int | No |
| name | string | String | No |
| username | string | String | No |
| email | string | String | No |
| address | object | Address | No |
| phone | string | String | No |
| website | string | String? | Yes |
| company | object | ({String name, String catchPhrase}) | No |

### Address
| field | JSON type | Dart type | nullable? |
| :--- | :--- | :--- | :--- |
| street | string | String | No |
| suite | string | String | No |
| city | string | String | No |
| zipcode | string | String | No |
| geo | object | Geo | No |

### Address.geo
| field | JSON type | Dart type | nullable? |
| :--- | :--- | :--- | :--- |
| lat | string | double (через double.parse) | No |
| lng | string | double (через double.parse) | No |

### Company
| field | JSON type | Dart type | nullable? |
| :--- | :--- | :--- | :--- |
| name | string | String | No |
| catchPhrase | string | String | No |
| bs | string | String (игнорируется в Dart Record) | No |

## Level 5: Two kinds of no network timings
- **Airplane mode (`SocketException`):** ~0.2 s (мгновенная ошибка маршрутизации от ОС)
- **Dead Wi-Fi without internet (`TimeoutException`):** ~10.0 s (срабатывает 10-секундный таймаут в `ApiClient`)


# Practice 12: Survive a Restart — Notes

## Level 1: Package Verdicts

1. **shared_preferences**: Verified publisher `flutter.dev`, released October 2026 (`^2.5.6`), all six platforms (Android, iOS, Linux, macOS, Web, Windows), 160 pub points, actively maintained with regular commits in `flutter/packages`, depends only on `flutter` and federated `shared_preferences_*` packages, BSD-3-Clause license.
2. **flutter_secure_storage**: Verified publisher `steenbakker.dev`, released October 2026 (`^11.2.0`), five platforms (Android, iOS, Linux, macOS, Windows), 160 pub points, actively maintained with regular commits and resolved issues, depends on `flutter`, `meta` and federated `flutter_secure_storage_*` packages, BSD-3-Clause license.
3. **path_provider**: Verified publisher `flutter.dev`, released June 2026 (`^2.1.6`), five platforms (Android, iOS, Linux, macOS, Windows), 160 pub points, actively maintained in `flutter/packages`, depends only on `flutter` and federated `path_provider_*` packages, BSD-3-Clause license.
4. **image_picker**: Verified publisher `flutter.dev`, released October 2026 (`^1.2.4`), all six platforms (Android, iOS, Linux, macOS, Web, Windows), 160 pub points, active maintenance in `flutter/packages`, depends on `flutter` and federated `image_picker_*` packages, Apache-2.0 and BSD-3-Clause license.
5. **permission_handler**: Verified publisher `baseflow.com`, released September 2026 (`^12.0.3`), four platforms (Android, iOS, Web, Windows), 160 pub points, actively maintained with regular commits, depends on `flutter` and `permission_handler_*` platform packages, MIT license.
6. **url_launcher**: Verified publisher `flutter.dev`, released October 2026 (`^6.3.3`), all six platforms (Android, iOS, Linux, macOS, Web, Windows), 160 pub points, actively maintained in `flutter/packages`, depends on `flutter` and federated `url_launcher_*` packages, BSD-3-Clause license.

## Level 1: Caret (`^`) and `pubspec.lock`

* **Exact `http` version in `pubspec.lock`**: `1.6.0`.
* **What `http: ^1.2.0` accepts and refuses**: Under Semantic Versioning, `^1.2.0` is shorthand for `>=1.2.0 <2.0.0` — it accepts any non-breaking minor or patch update (`1.2.1`, `1.3.0`, `1.6.0`), while refusing older versions (`<1.2.0`) and breaking major releases (`2.0.0` and above).
* **Why `pubspec.lock` is committed for an app**: An application must build reproducibly on every teammate's laptop, in CI, and at the defence — committing `pubspec.lock` pins exact versions of all direct and transitive dependencies so an upstream release cannot unexpectedly break the build (unlike reusable library packages, where `pubspec.lock` is gitignored).
* **`flutter pub outdated` note**: `cupertino_icons` is at `1.0.9` (`2.0.0` available) because `pubspec.yaml` constrains it to `^1.0.8`; similarly, transitive packages like `cross_file` (`0.3.5+5`, `0.4.0` available) and `material_color_utilities` (`0.13.0`, `0.13.1` available) were not upgraded because `image_picker` and `flutter_test` from the pinned Flutter SDK restrict their versions.

## Level 3: Token Storage & Platform Surprises

* **Where `prefs.setString('token', ...)` puts the token & who can read it**: It writes the token in plain text into an XML file (`/data/data/<package>/shared_prefs/...` on Android) or `.plist` file (`NSUserDefaults` on iOS) inside the app's data folder, where it can be read via device backups, root access, or a debug USB cable.
* **iOS Keychain surprise after uninstall**: Keychain items live outside the app's sandbox directory, so uninstalling the app on iOS does not automatically erase them — a fresh reinstall can still read the previous token unless explicitly cleared on first launch.
* **Android KeyStore surprise when lock screen is removed**: Keys in Android KeyStore can be bound to device lock-screen credentials (PIN/pattern/biometrics); if the user removes or resets the screen lock, Android may invalidate the cryptographic key and wipe access to stored secrets.

## Level 5: iOS Permission Sequence

* **How many "No"s on iOS until `permanentlyDenied`**: **One (1)**. On iOS, tapping "Don't Allow" once immediately moves the permission into `permanentlyDenied`; iOS never displays the system prompt a second time, and the user must enable it manually in Settings.
* **What the fourth Photos state is called**: **`limited`** (`PermissionStatus.limited`, introduced in iOS 14 when the user chooses "Select Photos..." and grants access only to specific images).