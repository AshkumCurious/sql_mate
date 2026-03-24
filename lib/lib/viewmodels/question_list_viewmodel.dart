import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/user_progress.dart';
import '../repositories/question_repository.dart';
import '../repositories/progress_repository.dart';
import '../core/providers.dart';

class QuestionListState {
  final List<SqlQuestion> questions;
  final Map<String, QuestionProgress> progress;
  final String? selectedCategory;
  final Difficulty? selectedDifficulty;
  final bool isLoading;
  final String? error;

  const QuestionListState({
    this.questions = const [],
    this.progress = const {},
    this.selectedCategory,
    this.selectedDifficulty,
    this.isLoading = false,
    this.error,
  });

  List<SqlQuestion> get filtered {
    return questions.where((q) {
      if (selectedCategory != null && q.category != selectedCategory) {
        return false;
      }
      if (selectedDifficulty != null && q.difficulty != selectedDifficulty) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> get categories =>
      questions.map((q) => q.category).toSet().toList()..sort();

  int get completedCount =>
      progress.values.where((p) => p.isCompleted).length;

  QuestionListState copyWith({
    List<SqlQuestion>? questions,
    Map<String, QuestionProgress>? progress,
    String? selectedCategory,
    Difficulty? selectedDifficulty,
    bool clearCategory = false,
    bool clearDifficulty = false,
    bool? isLoading,
    String? error,
  }) {
    return QuestionListState(
      questions: questions ?? this.questions,
      progress: progress ?? this.progress,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedDifficulty: clearDifficulty
          ? null
          : selectedDifficulty ?? this.selectedDifficulty,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


class QuestionListViewModel extends StateNotifier<QuestionListState> {
  final QuestionRepository _questionRepo;
  final ProgressRepository _progressRepo;

  QuestionListViewModel(this._questionRepo, this._progressRepo)
      : super(const QuestionListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final questions = await _questionRepo.getAllQuestions();
      final allProgress = await _progressRepo.getAllProgress();
      state = state.copyWith(
        questions: questions,
        progress: allProgress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  void filterByCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void filterByDifficulty(Difficulty? difficulty) {
    if (difficulty == null) {
      state = state.copyWith(clearDifficulty: true);
    } else {
      state = state.copyWith(selectedDifficulty: difficulty);
    }
  }

  void refreshProgress() async {
    final allProgress = await _progressRepo.getAllProgress();
    state = state.copyWith(progress: allProgress);
  }
}


final questionListViewModelProvider =
    StateNotifierProvider<QuestionListViewModel, QuestionListState>((ref) {
  return QuestionListViewModel(
    ref.read(questionRepositoryProvider),
    ref.read(progressRepositoryProvider),
  );
});
