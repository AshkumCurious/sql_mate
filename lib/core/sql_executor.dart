import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/question.dart';
import '../models/user_progress.dart';

class SqlExecutor {
  Future<SubmissionResult> evaluate({
    required SqlQuestion question,
    required String userQuery,
  }) async {
    Database? db;
    try {
      db = await buildDatabase(question);

      final expectedOutput = await runQuery(db, question.referenceQuery);

      List<Map<String, dynamic>> userOutput;
      try {
        userOutput = await runQuery(db, userQuery);
      } catch (e) {
        return SubmissionResult(
          isCorrect: false,
          userOutput: [],
          expectedOutput: expectedOutput,
          errorMessage: formatSqlError(e.toString()),
        );
      }

      final isCorrect = compareResults(expectedOutput, userOutput);

      return SubmissionResult(
        isCorrect: isCorrect,
        userOutput: userOutput,
        expectedOutput: expectedOutput,
        mismatch: isCorrect
            ? null
            : ResultMismatch(
                expectedRows: expectedOutput.length,
                actualRows: userOutput.length,
                expectedColumns: expectedOutput.isNotEmpty
                    ? expectedOutput.first.keys.toList()
                    : [],
                actualColumns:
                    userOutput.isNotEmpty ? userOutput.first.keys.toList() : [],
              ),
      );
    } catch (e) {
      return SubmissionResult(
        isCorrect: false,
        userOutput: [],
        expectedOutput: [],
        errorMessage: formatSqlError(e.toString()),
      );
    } finally {
      await db?.close();
    }
  }

  Future<List<Map<String, dynamic>>> runQuery(
    Database db,
    String query,
  ) async {
    final trimmed = query.trim();
    final upper = trimmed.toUpperCase();

    if (upper.startsWith('SELECT') || upper.startsWith('WITH')) {
      final results = await db.rawQuery(trimmed);
      return results.map((r) => Map<String, dynamic>.from(r)).toList();
    } else {
      await db.execute(trimmed);
      return [];
    }
  }

  Future<Database> buildDatabase(SqlQuestion question) async {
    final dbPath = path.join(
      await getDatabasesPath(),
      'sqleval${DateTime.now().microsecondsSinceEpoch}.db',
    );

    final db = await openDatabase(dbPath, version: 1);

    for (final tableSchema in question.schema) {
      await db.execute(tableSchema.toCreateStatement());
    }

    for (final entry in question.seedData) {
      final tableName = entry['table'] as String;
      final rows = entry['rows'] as List;
      for (final row in rows) {
        await db.insert(
          tableName,
          Map<String, dynamic>.from(row as Map),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    return db;
  }

  bool compareResults(
    List<Map<String, dynamic>> expected,
    List<Map<String, dynamic>> actual,
  ) {
    if (expected.length != actual.length) return false;
    if (expected.isEmpty) return true;

    for (int i = 0; i < expected.length; i++) {
      final eRow = normalizeRow(expected[i]);
      final aRow = normalizeRow(actual[i]);

      if (eRow.length != aRow.length) return false;
      for (final key in eRow.keys) {
        if (!aRow.containsKey(key)) return false;
        if (normalizeValue(eRow[key]) != normalizeValue(aRow[key])) {
          return false;
        }
      }
    }
    return true;
  }

  Map<String, dynamic> normalizeRow(Map<String, dynamic> row) {
    return {
      for (final entry in row.entries) entry.key.toLowerCase(): entry.value,
    };
  }

  dynamic normalizeValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().toLowerCase();
    if (value is double) return value.toStringAsFixed(6);
    return value.toString();
  }

  String formatSqlError(String raw) {
    final match = RegExp(r'DatabaseException\((.*?)\)').firstMatch(raw);
    return match?.group(1) ?? raw;
  }
}
