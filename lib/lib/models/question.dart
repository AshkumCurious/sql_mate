class SqlQuestion {
  final String id;
  final String title;
  final String description;
  final String category;
  final Difficulty difficulty;
  final List<TableSchema> schema;
  final List<Map<String, dynamic>> seedData;
  final String referenceQuery;
  final List<String> hints;
  final String? explanation;

  const SqlQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.schema,
    required this.seedData,
    required this.referenceQuery,
    required this.hints,
    this.explanation,
  });

  factory SqlQuestion.fromJson(Map<String, dynamic> json) {
    return SqlQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: Difficulty.fromString(json['difficulty'] as String),
      schema: (json['schema'] as List)
          .map((e) => TableSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
      seedData: (json['seed_data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      referenceQuery: json['reference_query'] as String,
      hints: List<String>.from(json['hints'] as List),
      explanation: json['explanation'] as String?,
    );
  }
}

class TableSchema {
  final String tableName;
  final List<ColumnDef> columns;

  const TableSchema({required this.tableName, required this.columns});

  factory TableSchema.fromJson(Map<String, dynamic> json) {
    return TableSchema(
      tableName: json['table_name'] as String,
      columns: (json['columns'] as List)
          .map((e) => ColumnDef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toCreateStatement() {
    final cols = columns.map((c) => '  ${c.name} ${c.type}').join(',\n');
    return 'CREATE TABLE IF NOT EXISTS $tableName (\n$cols\n);';
  }
}

class ColumnDef {
  final String name;
  final String type; // e.g. "INTEGER", "TEXT", "REAL"
  final bool isPrimary;
  final bool notNull;

  const ColumnDef({
    required this.name,
    required this.type,
    this.isPrimary = false,
    this.notNull = false,
  });

  factory ColumnDef.fromJson(Map<String, dynamic> json) {
    return ColumnDef(
      name: json['name'] as String,
      type: json['type'] as String,
      isPrimary: json['primary'] as bool? ?? false,
      notNull: json['not_null'] as bool? ?? false,
    );
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromString(String s) {
    return Difficulty.values.firstWhere(
      (d) => d.name == s.toLowerCase(),
      orElse: () => Difficulty.easy,
    );
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}
