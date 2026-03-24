import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/question.dart';
import '../../models/user_progress.dart';
import '../../viewmodels/practice_viewmodel.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/sql_editor.dart';
import '../widgets/result_table.dart';
import '../widgets/submission_banner.dart';
import '../widgets/schema_panel.dart';
import '../widgets/hint_panel.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final SqlQuestion question;
  final QuestionProgress? progress;

  const PracticeScreen({
    super.key,
    required this.question,
    this.progress,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final StateNotifierProvider<PracticeViewModel, PracticeState> _provider;

  @override
  void initState() {
    super.initState();
    _provider = makePracticeProvider(
      question: widget.question,
      progress:
          widget.progress ?? QuestionProgress(questionId: widget.question.id),
      progressRepo: ref.read(progressRepositoryProvider),
      executor: ref.read(sqlExecutorProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);
    final vm = ref.read(_provider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.question.title),
        actions: [
          _StatsRow(progress: state.progress),
          const Gap(12),
        ],
      ),
      body: _Body(state: state, vm: vm),
    );
  }
}

class _Body extends StatelessWidget {
  final PracticeState state;
  final PracticeViewModel vm;

  const _Body({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionCard(question: state.question),
                const Gap(12),
                SchemaPanel(
                  schema: state.question.schema,
                  isExpanded: state.showSchema,
                  onToggle: vm.toggleSchema,
                ),
                const Gap(12),
                SqlEditor(
                  initialValue: state.query,
                  onChanged: vm.updateQuery,
                  enabled: state.status != PracticeStatus.running,
                ),
                const Gap(12),
                if (state.status != PracticeStatus.idle &&
                    state.status != PracticeStatus.running)
                  SubmissionBanner(state: state),
                if (state.lastResult != null) ...[
                  const Gap(12),
                  _ResultSection(state: state, vm: vm),
                ],
                const Gap(12),
                HintPanel(
                  hints: state.visibleHints,
                  canRevealMore: state.canRevealMoreHints,
                  onRevealNext: vm.revealNextHint,
                ),
                const Gap(80),
              ],
            ),
          ),
        ),
        _ActionBar(state: state, vm: vm),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final SqlQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Gap(8),
              DifficultyBadge(difficulty: question.difficulty),
            ],
          ),
          const Gap(6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              question.category,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const Gap(10),
          Text(
            question.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final PracticeState state;
  final PracticeViewModel vm;

  const _ResultSection({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    final result = state.lastResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultTable(
          title: 'Your Output',
          rows: result.userOutput,
          accent: state.status == PracticeStatus.correct
              ? AppTheme.success
              : AppTheme.error,
        ),
        if (!state.isCompleted && state.status == PracticeStatus.wrong) ...[
          const Gap(8),
          TextButton.icon(
            onPressed: vm.toggleExpectedOutput,
            icon: Icon(
              state.showExpectedOutput
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 16,
            ),
            label: Text(state.showExpectedOutput
                ? 'Hide expected output'
                : 'Show expected output'),
          ),
          if (state.showExpectedOutput) ...[
            const Gap(4),
            ResultTable(
              title: 'Expected Output',
              rows: result.expectedOutput,
              accent: AppTheme.success,
            ),
          ],
        ],
        if (state.status == PracticeStatus.correct) ...[
          const Gap(8),
          ResultTable(
            title: 'Expected Output',
            rows: result.expectedOutput,
            accent: AppTheme.success,
          ),
          if (state.question.explanation != null) ...[
            const Gap(8),
            _ExplanationCard(explanation: state.question.explanation!),
          ],
        ],
      ],
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;

  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 18),
          const Gap(10),
          Expanded(
            child: Text(
              explanation,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final QuestionProgress progress;

  const _StatsRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          icon: Icons.send_rounded,
          value: progress.attempts.toString(),
          color: AppTheme.textMuted,
        ),
        const Gap(6),
        _StatPill(
          icon: Icons.check_circle_outline,
          value: progress.correctSubmissions.toString(),
          color: AppTheme.success,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final PracticeState state;
  final PracticeViewModel vm;

  const _ActionBar({required this.state, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isRunning = state.status == PracticeStatus.running;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  isRunning || state.query.trim().isEmpty ? null : vm.submit,
              icon: isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(isRunning ? 'Running...' : 'Run Query'),
            ),
          ),
          const Gap(10),
          OutlinedButton(
            onPressed: vm.reset,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

extension on PracticeState {
  bool get isCompleted => progress.isCompleted;
}
