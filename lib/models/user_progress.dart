class QuestionProgress {
  final String questionId;
  final int attempts;
  final int correctSubmissions;
  final bool isCompleted;
  final DateTime? lastAttemptAt;
  final int hintsUsed;

  const QuestionProgress({
    required this.questionId,
    this.attempts = 0,
    this.correctSubmissions = 0,
    this.isCompleted = false,
    this.lastAttemptAt,
    this.hintsUsed = 0,
  });

  QuestionProgress copyWith({
    int? attempts,
    int? correctSubmissions,
    bool? isCompleted,
    DateTime? lastAttemptAt,
    int? hintsUsed,
  }) {
    return QuestionProgress(
      questionId: questionId,
      attempts: attempts ?? this.attempts,
      correctSubmissions: correctSubmissions ?? this.correctSubmissions,
      isCompleted: isCompleted ?? this.isCompleted,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'attempts': attempts,
        'correctSubmissions': correctSubmissions,
        'isCompleted': isCompleted,
        'lastAttemptAt': lastAttemptAt?.toIso8601String(),
        'hintsUsed': hintsUsed,
      };

  factory QuestionProgress.fromJson(Map<String, dynamic> json) {
    return QuestionProgress(
      questionId: json['questionId'] as String,
      attempts: json['attempts'] as int? ?? 0,
      correctSubmissions: json['correctSubmissions'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
    );
  }
}

class SubmissionResult {
  final bool isCorrect;
  final List<Map<String, dynamic>> userOutput;
  final List<Map<String, dynamic>> expectedOutput;
  final String? errorMessage;
  final ResultMismatch? mismatch;

  const SubmissionResult({
    required this.isCorrect,
    required this.userOutput,
    required this.expectedOutput,
    this.errorMessage,
    this.mismatch,
  });
}

class ResultMismatch {
  final int expectedRows;
  final int actualRows;
  final List<String> expectedColumns;
  final List<String> actualColumns;

  const ResultMismatch({
    required this.expectedRows,
    required this.actualRows,
    required this.expectedColumns,
    required this.actualColumns,
  });
}
