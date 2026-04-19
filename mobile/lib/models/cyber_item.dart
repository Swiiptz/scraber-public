import 'package:cloud_firestore/cloud_firestore.dart';

class CyberSource {
  const CyberSource({required this.name, required this.url, this.category});

  final String name;
  final String url;
  final String? category;

  factory CyberSource.fromMap(Map<String, dynamic> map) {
    return CyberSource(
      name: (map['name'] ?? '') as String,
      url: (map['url'] ?? '') as String,
      category: map['category'] as String?,
    );
  }
}

class CyberItem {
  const CyberItem({
    required this.id,
    required this.editionNumber,
    required this.title,
    required this.content,
    required this.summary,
    required this.type,
    required this.level,
    required this.score,
    required this.date,
    required this.sources,
    required this.sourceUrls,
    required this.tags,
    required this.cves,
    this.cvss,
    this.product,
    this.vendor,
    this.threatType,
    this.exploited = false,
  });

  final String id;
  final int? editionNumber;
  final String title;
  final String content;
  final String summary;
  final String type;
  final String level;
  final int score;
  final DateTime date;
  final List<CyberSource> sources;
  final List<String> sourceUrls;
  final List<String> tags;
  final List<String> cves;
  final double? cvss;
  final String? product;
  final String? vendor;
  final String? threatType;
  final bool exploited;

  String? get primaryCve => cves.isNotEmpty ? cves.first : null;

  CyberSource? get primarySource => sources.isEmpty ? null : sources.first;

  factory CyberItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CyberItem.fromMap({...data, 'id': data['id'] ?? doc.id});
  }

  factory CyberItem.fromMap(Map<String, dynamic> map) {
    final rawCves = map['cves'];
    final cves = rawCves is List
        ? rawCves.map((e) => e.toString()).toList()
        : <String>[];
    if (cves.isEmpty && map['cve'] is String && (map['cve'] as String).isNotEmpty) {
      cves.add(map['cve'] as String);
    }

    return CyberItem(
      id: (map['id'] ?? '') as String,
      editionNumber: _asInt(map['edition_number']),
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      summary: (map['summary'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      level: (map['level'] ?? '') as String,
      score: _asInt(map['score']) ?? 0,
      date: _parseDate(map['date']),
      sources: ((map['sources'] ?? const []) as List)
          .whereType<Map>()
          .map((e) => CyberSource.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      sourceUrls: ((map['source_urls'] ?? const []) as List)
          .map((e) => e.toString())
          .toList(),
      tags: ((map['tags'] ?? const []) as List).map((e) => e.toString()).toList(),
      cves: cves,
      cvss: _asDouble(map['cvss']),
      product: map['product'] as String?,
      vendor: map['vendor'] as String?,
      threatType: map['threat_type'] as String?,
      exploited: (map['exploited'] ?? false) as bool,
    );
  }
}

DateTime _parseDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
