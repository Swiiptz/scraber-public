import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cyber_item.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return FirestoreItemRepository(FirebaseFirestore.instance);
});

final itemsStreamProvider = StreamProvider<List<CyberItem>>((ref) {
  return ref.watch(itemRepositoryProvider).watchAll();
});

abstract class ItemRepository {
  Stream<List<CyberItem>> watchAll({int limit = 500});

  Future<CyberItem> fetchItem(String id);
}

class FirestoreItemRepository implements ItemRepository {
  FirestoreItemRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('items');

  @override
  Stream<List<CyberItem>> watchAll({int limit = 500}) {
    return _items
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map(CyberItem.fromFirestore).toList();
          items.sort(compareImportance);
          return items;
        });
  }

  @override
  Future<CyberItem> fetchItem(String id) async {
    final doc = await _items.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('Contenu introuvable');
    }
    return CyberItem.fromFirestore(doc);
  }
}

int compareImportance(CyberItem a, CyberItem b) {
  final levelComparison = levelRank(b.level).compareTo(levelRank(a.level));
  if (levelComparison != 0) return levelComparison;
  final scoreComparison = b.score.compareTo(a.score);
  if (scoreComparison != 0) return scoreComparison;
  return b.date.compareTo(a.date);
}

int levelRank(String level) {
  return switch (level.toUpperCase()) {
    'CRITIQUE' => 4,
    'ELEVEE' => 3,
    'MOYENNE' => 2,
    'FAIBLE' => 1,
    _ => 0,
  };
}

Map<String, List<String>> filtersFromItems(List<CyberItem> items) {
  return {
    'types': (items.map((item) => item.type).toSet().toList()..sort()),
    'levels': (items.map((item) => item.level).toSet().toList()
      ..sort((a, b) => levelRank(b).compareTo(levelRank(a)))),
    'sources': (items
        .expand((item) => item.sources.map((source) => source.name))
        .toSet()
        .toList()
      ..sort()),
    'tags': (items.expand((item) => item.tags).toSet().toList()..sort()),
  };
}
