import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import '../widgets/match_card.dart';
import '../widgets/scoreboard_card.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoTo});
  final void Function(int index) onGoTo;

  void _open(BuildContext context, MatchModel m) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: m.matchId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final live = app.liveMatches;
    final upcoming = app.upcomingMatches.take(3).toList();
    final recent = app.completedMatches.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Header: logo + app name
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, Color(0xFF2979FF)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports_basketball, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kAppName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(kAppSubtitle,
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Stats
        Row(
          children: [
            Expanded(child: _StatTile(label: 'Teams', value: '${app.teams.length}', icon: Icons.groups)),
            const SizedBox(width: 12),
            Expanded(child: _StatTile(label: 'Matches', value: '${app.matches.length}', icon: Icons.event_available)),
          ],
        ),
        const SizedBox(height: 12),

        // Quick access
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => onGoTo(1),
                icon: const Icon(Icons.calendar_month),
                label: const Text('Schedule'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => onGoTo(3),
                icon: const Icon(Icons.leaderboard),
                label: const Text('Standings'),
              ),
            ),
          ],
        ),

        const SectionHeader('Live now'),
        if (live.isEmpty)
          const EmptyState(icon: Icons.sports_score, message: 'No live match right now.')
        else
          for (final m in live) ScoreboardCard(match: m, onTap: () => _open(context, m)),

        SectionHeader('Upcoming matches', actionLabel: 'See all', onAction: () => onGoTo(1)),
        if (upcoming.isEmpty)
          const EmptyState(icon: Icons.event, message: 'No upcoming matches scheduled.')
        else
          for (final m in upcoming) MatchCard(match: m, onTap: () => _open(context, m)),

        SectionHeader('Recent results', actionLabel: 'Standings', onAction: () => onGoTo(3)),
        if (recent.isEmpty)
          const EmptyState(icon: Icons.emoji_events, message: 'No completed matches yet.')
        else
          for (final m in recent) MatchCard(match: m, onTap: () => _open(context, m)),

        if (app.teams.isEmpty && app.matches.isEmpty) ...[
          const SizedBox(height: 16),
          const EmptyState(
            icon: Icons.info_outline,
            message: 'No data yet. Open the Admin tab (PIN required) and use '
                '"Load sample data" or add teams and matches.',
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
