import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../theme/app_colors.dart';

class StageColumn extends StatelessWidget {
  final Stage stage;
  final List<Task> tasks;
  final Function(Task, Stage)? onTaskMoved;
  final Function(Task)? onTaskTap;
  final Function(Task)? onTaskEdit;
  final Function(Task)? onTaskDelete;
  final VoidCallback? onAddTask;

  const StageColumn({
    super.key,
    required this.stage,
    required this.tasks,
    this.onTaskMoved,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок колонки
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _getStageColor(stage.name).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(
                color: _getStageColor(stage.name).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  stage.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStageColor(stage.name),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStageColor(stage.name).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStageColor(stage.name),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Список задач
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  left: BorderSide(
                    color: _getStageColor(stage.name).withOpacity(0.3),
                    width: 1,
                  ),
                  right: BorderSide(
                    color: _getStageColor(stage.name).withOpacity(0.3),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: _getStageColor(stage.name).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: tasks.length,
                      onReorder: (oldIndex, newIndex) {
                        // Обработка переупорядочивания задач
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        // Здесь можно добавить логику обновления порядка
                      },
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          onTap: () => onTaskTap?.call(task),
                          onEdit: () => onTaskEdit?.call(task),
                          onDelete: () => onTaskDelete?.call(task),
                        );
                      },
                    ),
            ),
          ),
          
          // Кнопка добавления задачи
          if (onAddTask != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Добавить задачу'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStageColor(stage.name).withOpacity(0.1),
                  foregroundColor: _getStageColor(stage.name),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _getStageColor(stage.name).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: 48,
              color: _getStageColor(stage.name).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет задач',
              style: TextStyle(
                fontSize: 16,
                color: _getStageColor(stage.name).withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую задачу',
              style: TextStyle(
                fontSize: 12,
                color: _getStageColor(stage.name).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStageColor(String stageName) {
    switch (stageName) {
      case 'to_do':
        return AppColors.info;
      case 'in_progress':
        return AppColors.warning;
      case 'review':
        return AppColors.primary;
      case 'done':
        return AppColors.success;
      default:
        return AppColors.gray600;
    }
  }
}
