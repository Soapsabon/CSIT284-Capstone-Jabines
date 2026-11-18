import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import '../widgets/standings_row.dart';

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<AppProvider>().standings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Team Standings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (teams.isEmpty)
            const EmptyState(icon: Icons.groups, message: 'No teams yet.')
          else ...[
            const StandingsHeader(),
            for (var i = 0; i < teams.length; i++)
              StandingsRow(rank: i + 1, team: teams[i]),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Win = 3 pts · Loss = 0 pts · Ties broken by point difference (PD).',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
