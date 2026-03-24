import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import '../core/sql_executor.dart';

enum PracticeStatus { idle, running, correct, wrong, error }

class PracticeState {
  final SqlQuestion question;
  final QuestionProgress progress;
  final String query;
  final PracticeStatus status;
  final SubmissionResult? lastResult;
  final int revealedHints;
  final bool showExpectedOutput;
  final bool showSchema;

  const PracticeState({
    required this.question,
    required this.progress,
    this.query = '',
    this.status = PracticeStatus.idle,
    this.lastResult,
    this.revealedHints = 0,
    this.showExpectedOutput = false,
    this.showSchema = false,
  });

  bool get canRevealMoreHints => revealedHints < question.hints.length;
  List<String> get visibleHints => question.hints.take(revealedHints).toList();

  PracticeState copyWith({
    QuestionProgress? progress,
    String? query,
    PracticeStatus? status,
    SubmissionResult? lastResult,
    int? revealedHints,
    bool? showExpectedOutput,
    bool? showSchema,
  }) {
    return PracticeState(
      question: question,
      progress: progress ?? this.progress,
      query: query ?? this.query,
      status: status ?? this.status,
      lastResult: lastResult ?? this.lastResult,
      revealedHints: revealedHints ?? this.revealedHints,
      showExpectedOutput: showExpectedOutput ?? this.showExpectedOutput,
      showSchema: showSchema ?? this.showSchema,
    );
  }
}

class PracticeViewModel extends StateNotifier<PracticeState> {
  final ProgressRepository _progressRepo;
  final SqlExecutor _executor;

  PracticeViewModel({
    required SqlQuestion question,
    required QuestionProgress progress,
    required ProgressRepository progressRepo,
    required SqlExecutor executor,
  })  : _progressRepo = progressRepo,
        _executor = executor,
        super(PracticeState(question: question, progress: progress));

  void updateQuery(String query) {
    state = state.copyWith(query: query, status: PracticeStatus.idle);
  }

  Future<void> submit() async {
    if (state.query.trim().isEmpty) return;

    state = state.copyWith(status: PracticeStatus.running);

    final result = await _executor.evaluate(
      question: state.question,
      userQuery: state.query.trim(),
    );

    final newAttempts = state.progress.attempts + 1;
    final newCorrect = result.isCorrect
        ? state.progress.correctSubmissions + 1
        : state.progress.correctSubmissions;

    final updatedProgress = state.progress.copyWith(
      attempts: newAttempts,
      correctSubmissions: newCorrect,
      isCompleted: state.progress.isCompleted || result.isCorrect,
      lastAttemptAt: DateTime.now(),
    );

    await _progressRepo.saveProgress(updatedProgress);
    await _progressRepo.recordActivityToday();

    state = state.copyWith(
      progress: updatedProgress,
      status: result.isCorrect
          ? PracticeStatus.correct
          : result.errorMessage != null
              ? PracticeStatus.error
              : PracticeStatus.wrong,
      lastResult: result,
    );
  }

  void revealNextHint() {
    if (!state.canRevealMoreHints) return;
    final newCount = state.revealedHints + 1;
    final updatedProgress = state.progress.copyWith(
      hintsUsed: newCount > state.progress.hintsUsed
          ? newCount
          : state.progress.hintsUsed,
    );
    _progressRepo.saveProgress(updatedProgress);
    state = state.copyWith(
      revealedHints: newCount,
      progress: updatedProgress,
    );
  }

  void toggleExpectedOutput() {
    state = state.copyWith(
      showExpectedOutput: !state.showExpectedOutput,
    );
  }

  void toggleSchema() {
    state = state.copyWith(showSchema: !state.showSchema);
  }

  void reset() {
    state = state.copyWith(
      query: '',
      status: PracticeStatus.idle,
      showExpectedOutput: false,
    );
  }
}

final practiceViewModelProvider =
    StateNotifierProvider.family<PracticeViewModel, PracticeState, String>(
        (ref, questionId) {
  throw UnimplementedError(
    'Override with practiceViewModelProvider.overrideWith inside the screen',
  );
});

StateNotifierProvider<PracticeViewModel, PracticeState> makePracticeProvider({
  required SqlQuestion question,
  required QuestionProgress progress,
  required ProgressRepository progressRepo,
  required SqlExecutor executor,
}) {
  return StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
    return PracticeViewModel(
      question: question,
      progress: progress,
      progressRepo: progressRepo,
      executor: executor,
    );
  });
}
