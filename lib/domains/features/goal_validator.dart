class GoalValidator {
  /// タイトルが空かどうかを検証し、エラー時は例外を投げる
  static void validateTitleOrThrow(String title) {
    if (title.trim().isEmpty) {
      throw Exception('タイトルは必須です');
    }
  }
  // 必要に応じて他のバリデーションも追加可能
}