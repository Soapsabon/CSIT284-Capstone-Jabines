import 'package:flutter_test/flutter_test.dart';
import 'package:x3_intrams/models/match_model.dart';
import 'package:x3_intrams/utils/constants.dart';
import 'package:x3_intrams/utils/standings.dart';

MatchModel _m(String a, String b, int sa, int sb, String status) => MatchModel(
      matchId: '$a$b',
      teamAId: a,
      teamBId: b,
      teamAName: a,
      teamBName: b,
      scoreA: sa,
      scoreB: sb,
      matchDate: DateTime(2026, 11, 20),
      matchTime: '09:00',
      venue: 'Gym',
      status: status,
    );

void main() {
  test('win = 3 pts, loss = 0, point difference tracked', () {
    final stats = computeStats(['A', 'B'], [_m('A', 'B', 80, 70, MatchStatus.completed)]);
    expect(stats['A']!.points, 3);
    expect(stats['A']!.w, 1);
    expect(stats['A']!.diff, 10);
    expect(stats['B']!.points, 0);
    expect(stats['B']!.l, 1);
    expect(stats['B']!.diff, -10);
  });

  test('live and upcoming matches do not count', () {
    final stats = computeStats(['A', 'B'], [
      _m('A', 'B', 10, 5, MatchStatus.live),
      _m('A', 'B', 0, 0, MatchStatus.upcoming),
    ]);
    expect(stats['A']!.gp, 0);
    expect(stats['B']!.gp, 0);
  });

  test('editing a completed score recomputes from scratch', () {
    var stats = computeStats(['A', 'B'], [_m('A', 'B', 60, 50, MatchStatus.completed)]);
    expect(stats['A']!.w, 1);
    stats = computeStats(['A', 'B'], [_m('A', 'B', 50, 60, MatchStatus.completed)]);
    expect(stats['A']!.w, 0);
    expect(stats['B']!.w, 1);
  });
}
