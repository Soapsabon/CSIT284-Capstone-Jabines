import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../models/team.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../utils/dialogs.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import '../widgets/status_chip.dart';
import '../widgets/team_card.dart';
import 'match_form_screen.dart';

/// DEMO-ONLY admin area. The PIN gate is not real security (see README).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AppProvider>().isAdmin;
    return isAdmin ? const _AdminHome() : const _PinGate();
  }
}

// ------------------------------------------------------------------ PIN gate

class _PinGate extends StatefulWidget {
  const _PinGate();

  @override
  State<_PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<_PinGate> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = context.read<AppProvider>().unlockAdmin(_ctrl.text.trim());
    if (!ok) setState(() => _error = 'Incorrect PIN');
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Admin')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 44, color: AppColors.primary),
              const SizedBox(height: 14),
              const Text('Administrator access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Demo-only PIN. Not production security.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'PIN',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _submit, child: const Text('Unlock')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Admin home

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'lock') {
                  app.lockAdmin();
                } else if (v == 'seed') {
                  final ok = await confirmDialog(
                    context,
                    title: 'Load sample data?',
                    message: 'Adds 4 sample teams and 5 sample matches '
                        '(flagged as SAMPLE). Real records are not touched.',
                    confirmLabel: 'Load',
                  );
                  if (ok && context.mounted) {
                    await runGuarded(context, app.seedSampleData,
                        success: 'Sample data loaded.');
                  }
                } else if (v == 'clear') {
                  final ok = await confirmDialog(
                    context,
                    title: 'Remove sample data?',
                    message: 'Deletes only records flagged as SAMPLE.',
                    confirmLabel: 'Remove',
                    destructive: true,
                  );
                  if (ok && context.mounted) {
                    await runGuarded(context, app.clearSampleData,
                        success: 'Sample data removed.');
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'seed', child: Text('Load sample data')),
                PopupMenuItem(value: 'clear', child: Text('Remove sample data')),
                PopupMenuItem(value: 'lock', child: Text('Lock admin')),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Matches'), Tab(text: 'Teams')]),
        ),
        body: const TabBarView(children: [_MatchesTab(), _TeamsTab()]),
      ),
    );
  }
}

// ------------------------------------------------------------------ Matches tab

class _MatchesTab extends StatelessWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add match'),
        onPressed: () {
          if (app.teams.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add at least 2 teams first.')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MatchFormScreen()),
          );
        },
      ),
      body: app.matches.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyState(icon: Icons.event, message: 'No matches yet. Tap "Add match".'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [for (final m in app.matches) _AdminMatchTile(match: m)],
            ),
    );
  }
}

class _AdminMatchTile extends StatelessWidget {
  const _AdminMatchTile({required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();
    final m = match;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${m.code}',
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              StatusChip(m.status),
              if (m.isSample) ...[
                const SizedBox(width: 8),
                const Text('SAMPLE',
                    style: TextStyle(color: AppColors.upcoming, fontSize: 10)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('${m.teamAName} vs ${m.teamBName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${fmtDate(m.matchDate)} · ${fmtTime(m.matchTime)} · ${m.venue}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          if (m.isLive) ...[
            const SizedBox(height: 12),
            _ScorePad(match: m),
          ] else if (m.isCompleted) ...[
            const SizedBox(height: 8),
            Text('Final: ${m.scoreA} - ${m.scoreB}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (m.isUpcoming)
                FilledButton.tonal(
                  onPressed: () => runGuarded(
                    context,
                    () => app.setStatus(m, MatchStatus.live),
                    success: 'Match is now LIVE.',
                  ),
                  child: const Text('Start match'),
                ),
              if (m.isLive)
                FilledButton(
                  onPressed: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'Mark as completed?',
                      message: 'Final score ${m.scoreA} - ${m.scoreB}. '
                          'Team standings will be updated.',
                      confirmLabel: 'Complete',
                    );
                    if (ok && context.mounted) {
                      await runGuarded(
                        context,
                        () => app.setStatus(m, MatchStatus.completed),
                        success: 'Match completed. Standings updated.',
                      );
                    }
                  },
                  child: const Text('Complete match'),
                ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MatchFormScreen(match: m)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.live),
                onPressed: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Delete match?',
                    message: '${m.teamAName} vs ${m.teamBName} will be permanently deleted '
                        'and standings recalculated.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (ok && context.mounted) {
                    await runGuarded(
                      context,
                      () => app.deleteMatch(m.matchId),
                      success: 'Match deleted.',
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick score buttons for a LIVE match (-1, +1, +2, +3 per team).
class _ScorePad extends StatelessWidget {
  const _ScorePad({required this.match});
  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _side(context, match.teamAName, match.scoreA, true)),
        const SizedBox(width: 10),
        Expanded(child: _side(context, match.teamBName, match.scoreB, false)),
      ],
    );
  }

  Widget _side(BuildContext context, String name, int score, bool isA) {
    final app = context.read<AppProvider>();

    Widget btn(String label, int delta) => OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          onPressed: () {
            final a = isA ? score + delta : match.scoreA;
            final b = isA ? match.scoreB : score + delta;
            runGuarded(context, () => app.updateScore(match, a, b));
          },
          child: Text(label),
        );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text('$score', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [btn('-1', -1), btn('+1', 1), btn('+2', 2), btn('+3', 3)],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Teams tab

class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add team'),
        onPressed: () => showDialog(context: context, builder: (_) => const _TeamDialog()),
      ),
      body: app.teams.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyState(icon: Icons.groups, message: 'No teams yet. Tap "Add team".'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                for (final t in app.teams)
                  TeamCard(
                    team: t,
                    onEdit: () => showDialog(
                      context: context,
                      builder: (_) => _TeamDialog(team: t),
                    ),
                    onDelete: () async {
                      final ok = await confirmDialog(
                        context,
                        title: 'Delete team?',
                        message: '${t.teamName} will be permanently deleted.',
                        confirmLabel: 'Delete',
                        destructive: true,
                      );
                      if (ok && context.mounted) {
                        await runGuarded(
                          context,
                          () => app.deleteTeam(t.teamId),
                          success: 'Team deleted.',
                        );
                      }
                    },
                  ),
              ],
            ),
    );
  }
}

class _TeamDialog extends StatefulWidget {
  const _TeamDialog({this.team});
  final Team? team;

  @override
  State<_TeamDialog> createState() => _TeamDialogState();
}

class _TeamDialogState extends State<_TeamDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.team?.teamName ?? '');
  late final TextEditingController _logo =
      TextEditingController(text: widget.team?.logoUrl ?? '');
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _logo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final isEdit = widget.team != null;
    setState(() => _saving = true);
    try {
      await app.saveTeam(id: widget.team?.teamId, name: _name.text, logoUrl: _logo.text);
      nav.pop();
      messenger.showSnackBar(SnackBar(content: Text(isEdit ? 'Team updated.' : 'Team added.')));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.team == null ? 'Add team' : 'Edit team'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Team name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Team name is required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _logo,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Logo URL (optional)',
                helperText: 'Leave empty to use an initial badge',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
      ],
    );
  }
}
