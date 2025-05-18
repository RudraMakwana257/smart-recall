import 'storage_interface.dart';
import 'memory_storage.dart' if (dart.library.html) 'web_storage.dart';

DeckStorage getStorage() => StorageImpl();
