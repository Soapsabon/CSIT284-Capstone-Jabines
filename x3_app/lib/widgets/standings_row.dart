import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/theme.dart';
import 'team_logo.dart';

class StandingsHeader extends StatelessWidget {
  const StandingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const s = TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 26, child: Text('#', style: s)),
          Expanded(child: Text('TEAM', style: s)),
          SizedBox(width: 30, child: Text('GP', style: s, textAlign: TextAlign.center)),
          SizedBox(width: 26, child: Text('W', style: s, textAlign: TextAlign.center)),
          SizedBox(width: 26, child: Text('L', style: s, textAlign: TextAlign.center)),
          SizedBox(width: 36, child: Text('PD', style: s, textAlign: TextAlign.center)),
          SizedBox(width: 38, child: Text('PTS', style: s, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class StandingsRow extends StatelessWidget {
  const StandingsRow({super.key, required this.rank, required this.team});
  final int rank;
  final Team team;

  @override
  Widget build(BuildContext context) {
    final leader = rank == 1;
    const cell = TextStyle(fontWeight: FontWeight.w600);
    final pd = team.pointDifference;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: leader ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: leader ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text('$rank',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: leader ? AppColors.primary : Colors.white)),
          ),
          TeamLogo(name: team.teamName, url: team.logoUrl, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(team.teamName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
              width: 30,
              child: Text('${team.gamesPlayed}', textAlign: TextAlign.center, style: cell)),
          SizedBox(
              width: 26,
              child: Text('${team.wins}', textAlign: TextAlign.center, style: cell)),
          SizedBox(
              width: 26,
              child: Text('${team.losses}', textAlign: TextAlign.center, style: cell)),
          SizedBox(
              width: 36,
              child: Text(pd > 0 ? '+$pd' : '$pd',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12))),
          SizedBox(
              width: 38,
              child: Text('${team.points}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
        ],
      ),
    );
  }
}
