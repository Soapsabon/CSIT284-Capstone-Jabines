import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  const Team({
    required this.teamId,
    required this.teamName,
    this.logoUrl = '',
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
    this.pointsScored = 0,
    this.pointsAgainst = 0,
    this.pointDifference = 0,
    this.isSample = false,
  });

  final String teamId;
  final String teamName;
  final String logoUrl;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int points;
  final int pointsScored;
  final int pointsAgainst;
  final int pointDifference;

  /// True for demo data created by "Load sample data" (kept separate from real records).
  final bool isSample;

  factory Team.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    int n(String k) => (d[k] as num?)?.toInt() ?? 0;
    return Team(
      teamId: doc.id,
      teamName: d['teamName'] as String? ?? '',
      logoUrl: d['logoUrl'] as String? ?? '',
      gamesPlayed: n('gamesPlayed'),
      wins: n('wins'),
      losses: n('losses'),
      points: n('points'),
      pointsScored: n('pointsScored'),
      pointsAgainst: n('pointsAgainst'),
      pointDifference: n('pointDifference'),
      isSample: d['isSample'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'teamId': teamId,
        'teamName': teamName,
        'logoUrl': logoUrl,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'losses': losses,
        'points': points,
        'pointsScored': pointsScored,
        'pointsAgainst': pointsAgainst,
        'pointDifference': pointDifference,
        'isSample': isSample,
      };
}
