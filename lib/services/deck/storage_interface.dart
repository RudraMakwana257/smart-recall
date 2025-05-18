// lib/services/deck/storage_interface.dart
abstract class DeckStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
