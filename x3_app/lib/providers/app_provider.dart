import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/match_model.dart';
import '../models/team.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._svc) {
    _teamSub = _svc.watchTeams().listen((v) {
      teams = v;
      _teamsLoaded = true;
      _refresh();
    }, onError: _onError);
    _matchSub = _svc.watchMatches().listen((v) {
      matches = v;
      _matchesLoaded = true;
      _refresh();
    }, onError: _onError);
  }

  final FirestoreService _svc;
  StreamSubscription<List<Team>>? _teamSub;
  StreamSubscription<List<MatchModel>>? _matchSub;
  bool _teamsLoaded = false;
  bool _matchesLoaded = false;

  List<Team> teams = [];
  List<MatchModel> matches = [];
  bool loading = true;
  String? error;
  bool isAdmin = false;

  void _refresh() {
    loading = !(_teamsLoaded && _matchesLoaded);
    error = null;
    notifyListeners();
  }

  void _onError(Object e) {
    error = e.toString();
    loading = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ derived data

  List<MatchModel> get liveMatches => matches.where((m) => m.isLive).toList();
  List<MatchModel> get upcomingMatches => matches.where((m) => m.isUpcoming).toList();
  List<MatchModel> get completedMatches =>
      matches.where((m) => m.isCompleted).toList().reversed.toList(); // newest first

  /// Points desc, then point difference desc, then name.
  List<Team> get standings {
    final list = [...teams];
    list.sort((a, b) {
      final p = b.points.compareTo(a.points);
      if (p != 0) return p;
      final d = b.pointDifference.compareTo(a.pointDifference);
      if (d != 0) return d;
      return a.teamName.compareTo(b.teamName);
    });
    return list;
  }

  MatchModel? matchById(String id) {
    for (final m in matches) {
      if (m.matchId == id) return m;
    }
    return null;
  }

  Team? teamById(String id) {
    for (final t in teams) {
      if (t.teamId == id) return t;
    }
    return null;
  }

  String logoOf(String teamId) => teamById(teamId)?.logoUrl ?? '';

  // ------------------------------------------------------------ admin gate (DEMO ONLY)

  bool unlockAdmin(String pin) {
    if (pin == kAdminPin) {
      isAdmin = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockAdmin() {
    isAdmin = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ actions (delegate to service)

  String newMatchId() => _svc.newMatchId();
  Future<void> saveMatch(MatchModel m, {required bool isNew}) =>
      _svc.saveMatch(m, isNew: isNew);
  Future<void> deleteMatch(String id) => _svc.deleteMatch(id);
  Future<void> updateScore(MatchModel m, int a, int b) => _svc.updateScore(m, a, b);
  Future<void> setStatus(MatchModel m, String status) => _svc.setStatus(m, status);
  Future<void> saveTeam({String? id, required String name, String logoUrl = ''}) =>
      _svc.saveTeam(id: id, name: name, logoUrl: logoUrl);
  Future<void> deleteTeam(String id) => _svc.deleteTeam(id);
  Future<void> seedSampleData() => _svc.seedSampleData();
  Future<void> clearSampleData() => _svc.clearSampleData();

  @override
  void dispose() {
    _teamSub?.cancel();
    _matchSub?.cancel();
    super.dispose();
  }
}
