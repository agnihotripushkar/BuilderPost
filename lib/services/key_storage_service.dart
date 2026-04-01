import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'gemini_api_key';

  static Future<String?> getKey() => _storage.read(key: _keyName);

  static Future<void> saveKey(String key) =>
      _storage.write(key: _keyName, value: key.trim());

  static Future<void> deleteKey() => _storage.delete(key: _keyName);
}
