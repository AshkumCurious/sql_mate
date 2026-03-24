import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../viewmodels/practice_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class SubmissionBanner extends StatelessWidget {
  final PracticeState state;

  const SubmissionBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.status == PracticeStatus.correct;
    final isError = state.status == PracticeStatus.error;

    Color bg;
    Color fg;
    IconData icon;
    String title;
    String? subtitle;

    if (isCorrect) {
      bg = AppTheme.successLight;
      fg = AppTheme.success;
      icon = Icons.check_circle_rounded;
      title = 'Correct!';
      subtitle = state.progress.correctSubmissions == 1
          ? 'First try! 🎉'
          : 'Solved in ${state.progress.attempts} attempt${state.progress.attempts == 1 ? '' : 's'}';
    } else if (isError) {
      bg = AppTheme.errorLight;
      fg = AppTheme.error;
      icon = Icons.error_outline_rounded;
      title = 'SQL Error';
      subtitle = state.lastResult?.errorMessage;
    } else {
      bg = AppTheme.warningLight;
      fg = AppTheme.warning;
      icon = Icons.close_rounded;
      final m = state.lastResult?.mismatch;
      title = 'Wrong Answer';
      if (m != null) {
        if (m.expectedRows != m.actualRows) {
          subtitle =
              'Expected ${m.expectedRows} row${m.expectedRows == 1 ? '' : 's'}, got ${m.actualRows}';
        } else if (!_sameColumns(m.expectedColumns, m.actualColumns)) {
          subtitle = 'Column mismatch';
        } else {
          subtitle = 'Row values do not match';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: fg.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _sameColumns(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = a.map((e) => e.toLowerCase()).toSet();
    final sb = b.map((e) => e.toLowerCase()).toSet();
    return sa.containsAll(sb);
  }
}
