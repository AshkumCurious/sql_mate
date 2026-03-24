import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../models/question.dart';
import '../../models/user_progress.dart';
import '../../core/theme/app_theme.dart';
import 'difficulty_badge.dart';

class QuestionCard extends StatelessWidget {
  final SqlQuestion question;
  final QuestionProgress? progress;
  final VoidCallback onTap;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.isCompleted ?? false;
    final attempts = progress?.attempts ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppTheme.success.withValues(alpha: 0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successLight
                    : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.code_rounded,
                size: 17,
                color: isCompleted ? AppTheme.success : AppTheme.textMuted,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          question.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      if (attempts > 0) ...[
                        const Gap(6),
                        Text(
                          '$attempts attempt${attempts == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Gap(10),
            DifficultyBadge(difficulty: question.difficulty),
            const Gap(6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
