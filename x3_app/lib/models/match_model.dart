import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class MatchModel {
  const MatchModel({
    required this.matchId,
    required this.teamAId,
    required this.teamBId,
    required this.teamAName,
    required this.teamBName,
    this.scoreA = 0,
    this.scoreB = 0,
    this.sportCategory = kSportCategory,
    required this.matchDate,
    required this.matchTime,
    required this.venue,
    this.status = MatchStatus.upcoming,
    this.createdAt,
    this.updatedAt,
    this.isSample = false,
  });

  final String matchId;
  final String teamAId;
  final String teamBId;
  final String teamAName;
  final String teamBName;
  final int scoreA;
  final int scoreB;
  final String sportCategory;
  final DateTime matchDate; // date only
  final String matchTime; // "HH:mm" 24h
  final String venue;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSample;

  /// Short, human-friendly ID for display (full ID is the Firestore doc ID).
  String get code {
    if (matchId.startsWith('sample_')) return matchId.substring(7);
    return matchId.substring(0, math.min(5, matchId.length)).toUpperCase();
  }

  DateTime get startsAt {
    final p = matchTime.split(':');
    final h = int.tryParse(p.first) ?? 0;
    final m = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
    return DateTime(matchDate.year, matchDate.month, matchDate.day, h, m);
  }

  bool get isLive => status == MatchStatus.live;
  bool get isCompleted => status == MatchStatus.completed;
  bool get isUpcoming => status == MatchStatus.upcoming;

  factory MatchModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return MatchModel(
      matchId: doc.id,
      teamAId: d['teamAId'] as String? ?? '',
      teamBId: d['teamBId'] as String? ?? '',
      teamAName: d['teamAName'] as String? ?? '',
      teamBName: d['teamBName'] as String? ?? '',
      scoreA: (d['scoreA'] as num?)?.toInt() ?? 0,
      scoreB: (d['scoreB'] as num?)?.toInt() ?? 0,
      sportCategory: d['sportCategory'] as String? ?? kSportCategory,
      matchDate: ts(d['matchDate']) ?? DateTime.now(),
      matchTime: d['matchTime'] as String? ?? '00:00',
      venue: d['venue'] as String? ?? '',
      status: d['status'] as String? ?? MatchStatus.upcoming,
      createdAt: ts(d['createdAt']),
      updatedAt: ts(d['updatedAt']),
      isSample: d['isSample'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap({bool isNew = false}) => {
        'matchId': matchId,
        'teamAId': teamAId,
        'teamBId': teamBId,
        'teamAName': teamAName,
        'teamBName': teamBName,
        'scoreA': scoreA,
        'scoreB': scoreB,
        'sportCategory': sportCategory,
        'matchDate': Timestamp.fromDate(
            DateTime(matchDate.year, matchDate.month, matchDate.day)),
        'matchTime': matchTime,
        'venue': venue,
        'status': status,
        'isSample': isSample,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      };

  MatchModel copyWith({int? scoreA, int? scoreB, String? status}) => MatchModel(
        matchId: matchId,
        teamAId: teamAId,
        teamBId: teamBId,
        teamAName: teamAName,
        teamBName: teamBName,
        scoreA: scoreA ?? this.scoreA,
        scoreB: scoreB ?? this.scoreB,
        sportCategory: sportCategory,
        matchDate: matchDate,
        matchTime: matchTime,
        venue: venue,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isSample: isSample,
      );
}
