import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/theme.dart';
import 'team_logo.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team, this.onEdit, this.onDelete});
  final Team team;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          TeamLogo(name: team.teamName, url: team.logoUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(team.teamName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    if (team.isSample) ...[
                      const SizedBox(width: 8),
                      const Text('SAMPLE',
                          style: TextStyle(color: AppColors.upcoming, fontSize: 10)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${team.wins}W - ${team.losses}L · ${team.points} pts',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.live),
            ),
        ],
      ),
    );
  }
}
