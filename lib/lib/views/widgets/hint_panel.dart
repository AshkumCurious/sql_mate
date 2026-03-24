import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../core/theme/app_theme.dart';

class HintPanel extends StatelessWidget {
  final List<String> hints;
  final bool canRevealMore;
  final VoidCallback onRevealNext;

  const HintPanel({
    super.key,
    required this.hints,
    required this.canRevealMore,
    required this.onRevealNext,
  });

  @override
  Widget build(BuildContext context) {
    if (hints.isEmpty && !canRevealMore) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Revealed hints
        ...hints.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HintTile(
                  index: entry.key + 1,
                  text: entry.value,
                ),
              ),
            ),

        // Reveal button
        if (canRevealMore)
          OutlinedButton.icon(
            onPressed: onRevealNext,
            icon: const Icon(Icons.lightbulb_outline_rounded, size: 15),
            label: Text(
              hints.isEmpty ? 'Show a hint' : 'Show next hint',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warning,
              side: BorderSide(color: AppTheme.warning.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
      ],
    );
  }
}

class _HintTile extends StatelessWidget {
  final int index;
  final String text;

  const _HintTile({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warning,
                ),
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
