import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../models/team.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';
import '../utils/standings.dart';

/// All Firebase logic lives here (UI never touches Firestore directly).
class FirestoreService {
  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _teams => _db.collection('teams');
  CollectionReference<Map<String, dynamic>> get _matches => _db.collection('matches');

  // ---------------------------------------------------------------- READ (real-time)

  Stream<List<Team>> watchTeams() =>
      _teams.snapshots().map((s) => s.docs.map(Team.fromDoc).toList());

  Stream<List<MatchModel>> watchMatches() => _matches.snapshots().map((s) {
        final list = s.docs.map(MatchModel.fromDoc).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        return list;
      });

  String newMatchId() => _matches.doc().id;

  // ---------------------------------------------------------------- MATCH CRUD

  void _validate(MatchModel m) {
    if (m.teamAId == m.teamBId) {
      throw AppException('Team A and Team B must be different teams.');
    }
    if (m.scoreA < 0 || m.scoreB < 0) {
      throw AppException('Scores cannot be negative.');
    }
    if (m.status == MatchStatus.completed && m.scoreA == m.scoreB) {
      throw AppException('A completed match cannot end in a tie. Adjust the score first.');
    }
  }

  /// Create or update a match. The match write and the standings recalculation
  /// are committed in ONE batch so they can never be out of sync.
  Future<void> saveMatch(MatchModel m, {required bool isNew}) async {
    _validate(m);
    final all = await _readAll();
    final matches = [...all.matches.where((x) => x.matchId != m.matchId), m];
    final batch = _db.batch();
    batch.set(_matches.doc(m.matchId), m.toMap(isNew: isNew), SetOptions(merge: true));
    _writeStandings(batch, all.teams, matches);
    await batch.commit();
  }

  Future<void> deleteMatch(String matchId) async {
    final all = await _readAll();
    final matches = all.matches.where((x) => x.matchId != matchId).toList();
    final batch = _db.batch();
    batch.delete(_matches.doc(matchId));
    _writeStandings(batch, all.teams, matches);
    await batch.commit();
  }

  /// Live score update. Only a single small write unless the match is already
  /// completed (then standings must be recalculated too).
  Future<void> updateScore(MatchModel m, int scoreA, int scoreB) async {
    final a = scoreA < 0 ? 0 : scoreA;
    final b = scoreB < 0 ? 0 : scoreB;
    if (m.status == MatchStatus.completed) {
      return saveMatch(m.copyWith(scoreA: a, scoreB: b), isNew: false);
    }
    await _matches.doc(m.matchId).update({
      'scoreA': a,
      'scoreB': b,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(MatchModel m, String status) =>
      saveMatch(m.copyWith(status: status), isNew: false);

  // ---------------------------------------------------------------- TEAM CRUD

  Future<void> saveTeam({String? id, required String name, String logoUrl = ''}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw AppException('Team name is required.');
    final batch = _db.batch();
    if (id == null) {
      final ref = _teams.doc();
      batch.set(ref, Team(teamId: ref.id, teamName: trimmed, logoUrl: logoUrl.trim()).toMap());
    } else {
      batch.update(_teams.doc(id), {'teamName': trimmed, 'logoUrl': logoUrl.trim()});
      // keep denormalised names on matches in sync
      final asA = await _matches.where('teamAId', isEqualTo: id).get();
      for (final d in asA.docs) {
        batch.update(d.reference, {'teamAName': trimmed});
      }
      final asB = await _matches.where('teamBId', isEqualTo: id).get();
      for (final d in asB.docs) {
        batch.update(d.reference, {'teamBName': trimmed});
      }
    }
    await batch.commit();
  }

  Future<void> deleteTeam(String id) async {
    final a = await _matches.where('teamAId', isEqualTo: id).limit(1).get();
    final b = await _matches.where('teamBId', isEqualTo: id).limit(1).get();
    if (a.docs.isNotEmpty || b.docs.isNotEmpty) {
      throw AppException('This team has matches. Delete or edit those matches first.');
    }
    await _teams.doc(id).delete();
  }

  // ---------------------------------------------------------------- SAMPLE DATA

  static const _sampleIds = [
    'sample_phoenix',
    'sample_titans',
    'sample_warriors',
    'sample_falcons',
  ];
  static const _sampleNames = [
    'Team Phoenix',
    'Team Titans',
    'Team Warriors',
    'Team Falcons',
  ];

  /// 4 teams, 2 completed, 1 live, 2 upcoming. Every doc is flagged isSample=true
  /// so it can be removed without touching real records.
  Future<void> seedSampleData() async {
    final now = DateTime.now();
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);

    MatchModel mk(String code, int a, int b, int sa, int sb, int dayOffset,
            String time, String venue, String status) =>
        MatchModel(
          matchId: 'sample_$code',
          teamAId: _sampleIds[a],
          teamBId: _sampleIds[b],
          teamAName: _sampleNames[a],
          teamBName: _sampleNames[b],
          scoreA: sa,
          scoreB: sb,
          matchDate: day(dayOffset),
          matchTime: time,
          venue: venue,
          status: status,
          isSample: true,
        );

    final sampleMatches = [
      mk('M01', 0, 1, 78, 72, -2, '09:00', 'Main Gym', MatchStatus.completed),
      mk('M02', 2, 3, 65, 70, -1, '14:00', 'Main Gym', MatchStatus.completed),
      mk('M03', 0, 2, 41, 38, 0, '15:30', 'Covered Court', MatchStatus.live),
      mk('M04', 1, 3, 0, 0, 1, '09:00', 'Main Gym', MatchStatus.upcoming),
      mk('M05', 3, 0, 0, 0, 2, '14:00', 'Covered Court', MatchStatus.upcoming),
    ];
    final sampleTeams = [
      for (var i = 0; i < 4; i++)
        Team(teamId: _sampleIds[i], teamName: _sampleNames[i], isSample: true),
    ];

    final all = await _readAll();
    final teams = [
      ...all.teams.where((t) => !_sampleIds.contains(t.teamId)),
      ...sampleTeams,
    ];
    final matches = [
      ...all.matches.where((m) => !m.isSample),
      ...sampleMatches,
    ];

    final batch = _db.batch();
    for (final t in sampleTeams) {
      batch.set(_teams.doc(t.teamId), t.toMap());
    }
    for (final m in sampleMatches) {
      batch.set(_matches.doc(m.matchId), m.toMap(isNew: true));
    }
    _writeStandings(batch, teams, matches);
    await batch.commit();
  }

  Future<void> clearSampleData() async {
    final all = await _readAll();
    final batch = _db.batch();
    for (final t in all.teams.where((t) => t.isSample)) {
      batch.delete(_teams.doc(t.teamId));
    }
    for (final m in all.matches.where((m) => m.isSample)) {
      batch.delete(_matches.doc(m.matchId));
    }
    _writeStandings(
      batch,
      all.teams.where((t) => !t.isSample).toList(),
      all.matches.where((m) => !m.isSample).toList(),
    );
    await batch.commit();
  }

  // ---------------------------------------------------------------- internals

  Future<({List<Team> teams, List<MatchModel> matches})> _readAll() async {
    final t = await _teams.get();
    final m = await _matches.get();
    return (
      teams: t.docs.map(Team.fromDoc).toList(),
      matches: m.docs.map(MatchModel.fromDoc).toList(),
    );
  }

  void _writeStandings(WriteBatch batch, List<Team> teams, List<MatchModel> matches) {
    final stats = computeStats(teams.map((t) => t.teamId), matches);
    for (final t in teams) {
      batch.update(_teams.doc(t.teamId), stats[t.teamId]!.toMap());
    }
  }
}
