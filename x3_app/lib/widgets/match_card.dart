import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import 'status_chip.dart';
import 'team_logo.dart';

/// Compact card used in schedule lists and the dashboard.
class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match, this.onTap});
  final MatchModel match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final showScore = !match.isUpcoming;
    final br = BorderRadius.circular(18);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: br),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'MATCH #${match.code}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (match.isSample) ...[
                      const SizedBox(width: 8),
                      const Text('SAMPLE',
                          style: TextStyle(color: AppColors.upcoming, fontSize: 10)),
                    ],
                    const Spacer(),
                    StatusChip(match.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TeamLogo(name: match.teamAName, url: app.logoOf(match.teamAId), size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(match.teamAName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (showScore)
                      Text('${match.scoreA}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TeamLogo(name: match.teamBName, url: app.logoOf(match.teamBId), size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(match.teamBName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (showScore)
                      Text('${match.scoreB}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event, size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(fmtDate(match.matchDate),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(fmtTime(match.matchTime),
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.place, size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(match.venue,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
