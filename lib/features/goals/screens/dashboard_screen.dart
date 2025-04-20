import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/screens/login_screen.dart';
import '../data/goals.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(userGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('マイゴール')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (_, index) {
            final goal = goals[index];
            return ListTile(
              title: Text(goal.title),
              subtitle: Text('状態: ${goal.status}'),
              onLongPress: () async{
                final user = ref.read(userProvider);
                if (user == null) return;

                await ref.read(goalRepositoryProvider).deleteGoal(user.uid, goal.id);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = ref.read(userProvider);
          if (user == null) return;

          final goal = Goal(
            id: const Uuid().v4(),
            title: '英単語100個覚える',
            status: 'todo',
            deadline: DateTime.now().add(const Duration(days: 3)),
          );

          await ref.read(goalRepositoryProvider).addGoal(user.uid, goal);
          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
