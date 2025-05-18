// lib/widgets/daily_goal_widget.dart
import 'package:flutter/material.dart';
import '../models/stats_model.dart';

class DailyGoalWidget extends StatelessWidget {
  final DailyGoal goal;

  const DailyGoalWidget({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.completed >= goal.target;
    final remaining = goal.target - goal.completed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Daily Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? '✅ You reviewed ${goal.completed} today — Great job!'
                  : '⚠️ Today: ${goal.completed} reviewed — $remaining more to go!',
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.completed / goal.target,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}