import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_exception.dart';
import '../utils/constants.dart';
import '../utils/dialogs.dart';
import '../utils/theme.dart';

/// Add (match == null) or edit a match.
class MatchFormScreen extends StatefulWidget {
  const MatchFormScreen({super.key, this.match});
  final MatchModel? match;

  @override
  State<MatchFormScreen> createState() => _MatchFormScreenState();
}

class _MatchFormScreenState extends State<MatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _venue;
  late final TextEditingController _scoreA;
  late final TextEditingController _scoreB;
  String? _teamAId;
  String? _teamBId;
  late DateTime _date;
  late TimeOfDay _time;
  late String _status;
  bool _saving = false;

  bool get _isEdit => widget.match != null;

  @override
  void initState() {
    super.initState();
    final m = widget.match;
    _venue = TextEditingController(text: m?.venue ?? '');
    _scoreA = TextEditingController(text: '${m?.scoreA ?? 0}');
    _scoreB = TextEditingController(text: '${m?.scoreB ?? 0}');
    _teamAId = m?.teamAId;
    _teamBId = m?.teamBId;
    _date = m?.matchDate ?? DateTime.now();
    final p = (m?.matchTime ?? '09:00').split(':');
    _time = TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p[1]) ?? 0);
    _status = m?.status ?? MatchStatus.upcoming;
  }

  @override
  void dispose() {
    _venue.dispose();
    _scoreA.dispose();
    _scoreB.dispose();
    super.dispose();
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  String? _scoreValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 0) return 'Whole number ≥ 0';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final teamA = app.teamById(_teamAId ?? '');
    final teamB = app.teamById(_teamBId ?? '');
    if (teamA == null || teamB == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Select both teams.')));
      return;
    }

    final a = int.parse(_scoreA.text.trim());
    final b = int.parse(_scoreB.text.trim());

    if (_status == MatchStatus.completed) {
      final ok = await confirmDialog(
        context,
        title: 'Mark as completed?',
        message: 'Final score $a - $b. Team standings will be updated.',
        confirmLabel: 'Save & complete',
      );
      if (!ok || !mounted) return;
    }

    final old = widget.match;
    final match = MatchModel(
      matchId: old?.matchId ?? app.newMatchId(),
      teamAId: teamA.teamId,
      teamBId: teamB.teamId,
      teamAName: teamA.teamName,
      teamBName: teamB.teamName,
      scoreA: a,
      scoreB: b,
      sportCategory: kSportCategory,
      matchDate: _date,
      matchTime: _hhmm(_time),
      venue: _venue.text.trim(),
      status: _status,
      isSample: old?.isSample ?? false,
    );

    setState(() => _saving = true);
    try {
      await app.saveMatch(match, isNew: !_isEdit);
      nav.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Match updated.' : 'Match added.')),
      );
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(e is AppException ? e.message : 'Could not save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<AppProvider>().teams;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit match' : 'Add match')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            DropdownButtonFormField<String>(
              value: teams.any((t) => t.teamId == _teamAId) ? _teamAId : null,
              decoration: const InputDecoration(labelText: 'Team A', border: OutlineInputBorder()),
              items: [
                for (final t in teams)
                  DropdownMenuItem(value: t.teamId, child: Text(t.teamName)),
              ],
              onChanged: (v) => setState(() => _teamAId = v),
              validator: (v) => v == null ? 'Select Team A' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: teams.any((t) => t.teamId == _teamBId) ? _teamBId : null,
              decoration: const InputDecoration(labelText: 'Team B', border: OutlineInputBorder()),
              items: [
                for (final t in teams)
                  DropdownMenuItem(value: t.teamId, child: Text(t.teamName)),
              ],
              onChanged: (v) => setState(() => _teamBId = v),
              validator: (v) {
                if (v == null) return 'Select Team B';
                if (v == _teamAId) return 'Team B must differ from Team A';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(DateFormat('EEE, MMM d, y').format(_date)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _venue,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Venue', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Venue is required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: [
                for (final s in MatchStatus.all)
                  DropdownMenuItem(value: s, child: Text(MatchStatus.label(s))),
              ],
              onChanged: (v) => setState(() => _status = v ?? MatchStatus.upcoming),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _scoreA,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Score A', border: OutlineInputBorder()),
                    validator: _scoreValidator,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _scoreB,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Score B', border: OutlineInputBorder()),
                    validator: _scoreValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Sport category: $kSportCategory (single category for this project)',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_saving ? 'Saving…' : 'Save match'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
