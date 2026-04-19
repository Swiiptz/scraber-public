import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService(Hive.box<String>('favorites'));
});

final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(favoritesServiceProvider).watch();
});

class FavoritesService {
  FavoritesService(this._box);

  final Box<String> _box;

  Set<String> get ids => _box.keys.cast<String>().toSet();

  Stream<Set<String>> watch() async* {
    yield ids;
    yield* _box.watch().map((_) => ids);
  }

  bool isFavorite(String id) => _box.containsKey(id);

  Future<void> toggle(String id) async {
    if (isFavorite(id)) {
      await _box.delete(id);
    } else {
      await _box.put(id, id);
    }
  }
}
