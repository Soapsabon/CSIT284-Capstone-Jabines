import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import 'status_chip.dart';
import 'team_logo.dart';

/// Large scoreboard-style card. Rebuilds automatically because the provider is
/// fed by Firestore snapshot listeners.
class ScoreboardCard extends StatelessWidget {
  const ScoreboardCard({super.key, required this.match, this.onTap});
  final MatchModel match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final br = BorderRadius.circular(22);
    final accent = AppColors.statusColor(match.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: br,
        border: Border.all(color: accent.withOpacity(match.isLive ? 0.9 : 0.25), width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(match.sportCategory.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    const Spacer(),
                    StatusChip(match.status),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _Side(
                          name: match.teamAName, logo: app.logoOf(match.teamAId)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: match.isUpcoming
                          ? const Text('VS',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.muted))
                          : Text(
                              '${match.scoreA} - ${match.scoreB}',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                    ),
                    Expanded(
                      child: _Side(
                          name: match.teamBName, logo: app.logoOf(match.teamBId)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.surfaceHigh),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event, size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text('${fmtDate(match.matchDate)} · ${fmtTime(match.matchTime)}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.place, size: 15, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(match.venue,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Last updated: ${fmtStamp(match.updatedAt)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.name, required this.logo});
  final String name;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(name: name, url: logo, size: 52),
        const SizedBox(height: 8),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
