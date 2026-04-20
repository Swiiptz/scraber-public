import 'package:flutter_test/flutter_test.dart';
import 'package:scraber/features/feed/feed_controller.dart';
import 'package:scraber/models/cyber_item.dart';

void main() {
  group('FeedFilters sorting', () {
    test('sorts newest first by default', () {
      final items = [
        _item(id: 'old', date: DateTime(2026, 4, 18)),
        _item(id: 'new', date: DateTime(2026, 4, 20)),
      ];

      final sorted = const FeedFilters().apply(items);

      expect(sorted.map((item) => item.id), ['new', 'old']);
    });

    test('sorts oldest first', () {
      final items = [
        _item(id: 'new', date: DateTime(2026, 4, 20)),
        _item(id: 'old', date: DateTime(2026, 4, 18)),
      ];

      final sorted =
          const FeedFilters(sortMode: FeedSortMode.oldest).apply(items);

      expect(sorted.map((item) => item.id), ['old', 'new']);
    });

    test('sorts by criticality then score then date', () {
      final items = [
        _item(
          id: 'medium',
          level: 'MOYENNE',
          score: 90,
          date: DateTime(2026, 4, 20),
        ),
        _item(
          id: 'critical-low-score',
          level: 'CRITIQUE',
          score: 50,
          date: DateTime(2026, 4, 18),
        ),
        _item(
          id: 'critical-high-score',
          level: 'CRITIQUE',
          score: 80,
          date: DateTime(2026, 4, 19),
        ),
      ];

      final sorted =
          const FeedFilters(sortMode: FeedSortMode.criticality).apply(items);

      expect(
        sorted.map((item) => item.id),
        ['critical-high-score', 'critical-low-score', 'medium'],
      );
    });
  });
}

CyberItem _item({
  required String id,
  String level = 'FAIBLE',
  int score = 10,
  required DateTime date,
}) {
  return CyberItem(
    id: id,
    editionNumber: null,
    title: id,
    content: '',
    summary: '',
    type: 'ACTUALITE',
    level: level,
    score: score,
    date: date,
    sources: const [],
    sourceUrls: const [],
    tags: const [],
    cves: const [],
  );
}
