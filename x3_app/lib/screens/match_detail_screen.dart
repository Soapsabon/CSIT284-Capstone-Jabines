import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import '../widgets/scoreboard_card.dart';

/// Scoreboard for a single match. Watches the provider, so it updates live.
class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.matchId});
  final String matchId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final m = app.matchById(matchId);

    return Scaffold(
      appBar: AppBar(title: const Text('Scoreboard')),
      body: m == null
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyState(icon: Icons.search_off, message: 'This match no longer exists.'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                ScoreboardCard(match: m),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _row('Match ID', '#${m.code}'),
                      _row('Sport', m.sportCategory),
                      _row('Date', fmtDate(m.matchDate)),
                      _row('Time', fmtTime(m.matchTime)),
                      _row('Venue', m.venue),
                      _row('Status', MatchStatus.label(m.status)),
                      _row('Last updated', fmtStamp(m.updatedAt)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(k, style: const TextStyle(color: AppColors.muted)),
            const Spacer(),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}
