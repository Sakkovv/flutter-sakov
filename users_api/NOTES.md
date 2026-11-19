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