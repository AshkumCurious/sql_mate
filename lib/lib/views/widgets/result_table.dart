import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ResultTable extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> rows;
  final Color accent;

  const ResultTable({
    super.key,
    required this.title,
    required this.rows,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _Wrapper(
        title: title,
        accent: accent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No rows returned.',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }

    final columns = rows.first.keys.toList();

    return _Wrapper(
      title: title,
      accent: accent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 40,
          horizontalMargin: 14,
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.05),
          ),
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(
                    col,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: rows
              .map(
                (row) => DataRow(
                  cells: columns
                      .map(
                        (col) => DataCell(
                          Text(
                            row[col]?.toString() ?? 'NULL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: row[col] == null
                                  ? Colors.white24
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Wrapper extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget child;

  const _Wrapper({
    required this.title,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
          child,
        ],
      ),
    );
  }
}
