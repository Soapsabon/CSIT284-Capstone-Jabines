import 'package:intl/intl.dart';

String fmtDate(DateTime d) => DateFormat('EEE, MMM d').format(d);

/// [hhmm] is stored as 24h "HH:mm" in Firestore.
String fmtTime(String hhmm) {
  final p = hhmm.split(':');
  final h = int.tryParse(p.first) ?? 0;
  final m = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
  return DateFormat('h:mm a').format(DateTime(2000, 1, 1, h, m));
}

String fmtStamp(DateTime? d) =>
    d == null ? '—' : DateFormat('MMM d, h:mm a').format(d);
