const String kAppName = 'X3 Intrams';
const String kAppSubtitle = 'Scoreboard & Schedule';

/// Only ONE sport category is supported (project scope).
const String kSportCategory = 'Basketball';

/// DEMO-ONLY admin access. This is NOT real security: anyone who decompiles
/// the app can read it. Documented as a known limitation in README.md.
const String kAdminPin = '2026';

class MatchStatus {
  static const String upcoming = 'upcoming';
  static const String live = 'live';
  static const String completed = 'completed';
  static const List<String> all = [upcoming, live, completed];

  static String label(String s) {
    switch (s) {
      case live:
        return 'Live';
      case completed:
        return 'Completed';
      default:
        return 'Upcoming';
    }
  }
}
