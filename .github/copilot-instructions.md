# プロジェクトの構成管理
## コミットメッセージの接頭辞ルール
コミットを行う場合には修正内容を明確にしてください。
また、コミットメッセージとファイルの修正は極力一致させること。内容が異なる場合は別のコミットメッセージを使用して、別のコミットとすること。
コミットメッセージの接頭辞は、以下のルールに従ってください。
- feat:     新機能
- fix:      バグ修正
- change:   仕様変更により、既存の機能に修正
- style:    コードスタイル
- clean:    コード修正/リファクタリング
- rename:   ファイル名変更
- docs:     ドキュメント
- perf:     パフォーマンス
- test:     テスト
- ci:       CI/CD
- revert:   変更の取り消し
- chore:    その他の変更(ビルドツールなどで生成されたファイルなど)

## 命名規則

- **クラス名**: UpperCamelCase（例: GoalRepository, GoalViewModel）
- **ファイル名**: snake_case（例: goal_repository.dart, goal_view_model.dart）
- **ディレクトリ名**: snake_case（例: model, repository, view_model）
- **Provider名**: xxxProvider（例: goalRepositoryProvider）
- **CRUDメソッド**: add, fetch, update, delete で統一（例: addGoal, fetchGoals）
- **変数名**: camelCase（例: goalId, userId, goalList）
- **リスト・複数形**: 必ず s を付ける（例: goals, tags, tasks）

##　その他
- アーキテクチャはMVVMを採用
- クリーンアーキテクチャに準拠する。
- 保守性、拡張性を重視し、機能ごとにディレクトリを分ける。