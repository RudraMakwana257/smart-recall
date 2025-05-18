import 'dart:html';
import 'storage_interface.dart';

class StorageImpl implements DeckStorage {
  @override
  Future<String?> read(String key) async => window.localStorage[key];

  @override
  Future<void> write(String key, String value) async {
    window.localStorage[key] = value;
  }
}
