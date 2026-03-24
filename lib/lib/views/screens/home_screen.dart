import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/question.dart';
import '../../viewmodels/question_list_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/question_card.dart';
import '../widgets/filter_chips.dart';
import '../widgets/stat_chip.dart';
import 'chat_bot.dart/chat_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionListViewModelProvider);
    final vm = ref.read(questionListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.auto_awesome_rounded, size: 18),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? _ErrorView(error: state.error!, onRetry: vm.refresh)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        total: state.questions.length,
                        completed: state.completedCount,
                      ),
                      _Filters(
                        categories: state.categories,
                        selectedCategory: state.selectedCategory,
                        selectedDifficulty: state.selectedDifficulty,
                        onCategoryChanged: vm.filterByCategory,
                        onDifficultyChanged: vm.filterByDifficulty,
                      ),
                      Expanded(
                        child: state.filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'No questions match the filters.',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount: state.filtered.length,
                                separatorBuilder: (_, __) => const Gap(10),
                                itemBuilder: (context, i) {
                                  final q = state.filtered[i];
                                  final progress = state.progress[q.id];
                                  return QuestionCard(
                                    question: q,
                                    progress: progress,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PracticeScreen(
                                            question: q,
                                            progress: progress,
                                          ),
                                        ),
                                      );
                                      vm.refreshProgress();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int total;
  final int completed;

  const _Header({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.terminal_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const Gap(10),
              Text(
                'SQL Mate',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              StatChip(
                label: 'Total',
                value: total.toString(),
                color: AppTheme.accent,
              ),
              const Gap(8),
              StatChip(
                label: 'Solved',
                value: completed.toString(),
                color: AppTheme.success,
              ),
              const Gap(8),
              StatChip(
                label: 'Remaining',
                value: (total - completed).toString(),
                color: AppTheme.textMuted,
              ),
            ],
          ),
          const Gap(16),
          const Divider(),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Difficulty? selectedDifficulty;
  final void Function(String?) onCategoryChanged;
  final void Function(Difficulty?) onDifficultyChanged;

  const _Filters({
    required this.categories,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterChipRow(
            label: 'Category',
            options: categories,
            selected: selectedCategory,
            onSelected: (v) =>
                onCategoryChanged(v == selectedCategory ? null : v),
          ),
          const Gap(8),
          FilterChipRow<Difficulty>(
            label: 'Difficulty',
            options: Difficulty.values,
            labelOf: (d) => d.label,
            selected: selectedDifficulty,
            onSelected: (v) => onDifficultyChanged(
              v == selectedDifficulty ? null : v,
            ),
          ),
          const Gap(12),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const Gap(12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const Gap(16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
