# CONTRIBUTING.md

## 命名規則

- **クラス名**: UpperCamelCase（例: GoalRepository, GoalViewModel）
- **ファイル名**: snake_case（例: goal_repository.dart, goal_view_model.dart）
- **ディレクトリ名**: snake_case（例: model, repository, view_model）
- **Provider名**: xxxProvider（例: goalRepositoryProvider）
- **CRUDメソッド**: add, fetch, update, delete で統一（例: addGoal, fetchGoals）
- **変数名**: camelCase（例: goalId, userId, goalList）
- **リスト・複数形**: 必ず s を付ける（例: goals, tags, tasks）

## ディレクトリ構成

```
lib/
  features/
    goals/
      model/
        goal.dart
        tag.dart
        task.dart
      repository/
        goal_repository.dart
        tag_repository.dart
      view_model/
        goal_view_model.dart
        tag_view_model.dart
      view/
        ...
      mapper/
        goal_mapper.dart
        tag_mapper.dart
    ...
```

## コメント・ドキュメンテーション

- 主要なクラス・メソッドには `///` で説明コメントを付与
- 引数や戻り値の型・用途も明記

## テスト

- テストファイルは `xxx_test.dart` で統一（例: goal_repository_test.dart）

---

このルールに従って開発・命名・ディレクトリ構成を行ってください。
