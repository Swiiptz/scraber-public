import 'package:intl/intl.dart';

/// Retourne une date relative courte en français : `il y a 2 h`, `hier`, `3 j`.
String relativeDateFr(DateTime date, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final delta = ref.difference(date);
  if (delta.isNegative) {
    return DateFormat('dd MMM', 'fr_FR').format(date);
  }
  final minutes = delta.inMinutes;
  if (minutes < 1) return 'à l\'instant';
  if (minutes < 60) return 'il y a $minutes min';
  final hours = delta.inHours;
  if (hours < 24) return 'il y a $hours h';
  final days = delta.inDays;
  if (days == 1) return 'hier';
  if (days < 7) return '$days j';
  if (days < 30) return '${(days / 7).floor()} sem';
  return DateFormat('dd MMM', 'fr_FR').format(date);
}

/// Date longue façon bandeau : `VEN. 18 AVR. 2026`.
String longHeaderDateFr(DateTime date) {
  return DateFormat("EEE. d MMM. y", 'fr_FR').format(date).toUpperCase();
}

/// Jour pivot (minuit local).
DateTime dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
