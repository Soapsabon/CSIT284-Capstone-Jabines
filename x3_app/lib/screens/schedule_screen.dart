import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/common.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final list = _filter == null
        ? app.matches
        : app.matches.where((m) => m.status == _filter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Match Schedule')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', null),
                for (final s in MatchStatus.all) _chip(MatchStatus.label(s), s),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            const EmptyState(icon: Icons.event_busy, message: 'No matches in this category.')
          else
            for (final m in list)
              MatchCard(
                match: m,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: m.matchId)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == value,
          onSelected: (_) => setState(() => _filter = value),
        ),
      );
}
