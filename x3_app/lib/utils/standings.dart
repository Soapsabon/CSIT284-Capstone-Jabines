import '../models/match_model.dart';
import '../utils/constants.dart';

class TeamStats {
  int gp = 0, w = 0, l = 0, pf = 0, pa = 0;
  int get points => w * 3; // Win = 3, Loss = 0
  int get diff => pf - pa; // tiebreaker

  Map<String, dynamic> toMap() => {
        'gamesPlayed': gp,
        'wins': w,
        'losses': l,
        'points': points,
        'pointsScored': pf,
        'pointsAgainst': pa,
        'pointDifference': diff,
      };
}

/// Recomputes every team's record from scratch using COMPLETED matches only.
/// Recomputing (instead of incrementing) keeps standings correct after edits/deletes.
Map<String, TeamStats> computeStats(
  Iterable<String> teamIds,
  Iterable<MatchModel> matches,
) {
  final stats = {for (final id in teamIds) id: TeamStats()};
  for (final m in matches) {
    if (m.status != MatchStatus.completed) continue;
    final a = stats[m.teamAId];
    final b = stats[m.teamBId];
    if (a == null || b == null) continue;
    a.gp++;
    b.gp++;
    a.pf += m.scoreA;
    a.pa += m.scoreB;
    b.pf += m.scoreB;
    b.pa += m.scoreA;
    if (m.scoreA > m.scoreB) {
      a.w++;
      b.l++;
    } else if (m.scoreB > m.scoreA) {
      b.w++;
      a.l++;
    }
  }
  return stats;
}
