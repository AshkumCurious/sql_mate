import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/question_repository.dart';
import '../repositories/progress_repository.dart';
import '../core/sql_executor.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final sqlExecutorProvider = Provider<SqlExecutor>((ref) {
  return SqlExecutor();
});
