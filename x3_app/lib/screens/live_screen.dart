import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common.dart';
import '../widgets/match_card.dart';
import '../widgets/scoreboard_card.dart';
import 'match_detail_screen.dart';

/// Live scoreboard tab. Data comes from Firestore snapshot listeners,
/// so scores change on screen without any manual refresh.
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final live = app.liveMatches;
    final next = app.upcomingMatches.take(2).toList();

    void open(String id) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: id)),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Live Scoreboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (live.isEmpty)
            const EmptyState(
              icon: Icons.sports_score,
              message: 'No live match right now. Scores appear here as soon as a match goes live.',
            )
          else
            for (final m in live) ScoreboardCard(match: m, onTap: () => open(m.matchId)),
          if (next.isNotEmpty) ...[
            const SectionHeader('Coming up next'),
            for (final m in next) MatchCard(match: m, onTap: () => open(m.matchId)),
          ],
        ],
      ),
    );
  }
}
