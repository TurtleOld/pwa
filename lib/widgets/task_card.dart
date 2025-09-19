import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: task.isOverdue ? AppColors.danger : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок задачи
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: task.state ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: task.state ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.state)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Описание задачи
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 8),
              
              // Метаданные
              Row(
                children: [
                  // Дедлайн
                  if (task.deadline != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.isOverdue 
                            ? AppColors.danger.withOpacity(0.1)
                            : AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: task.isOverdue ? AppColors.danger : AppColors.info,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            task.deadlineFormatted,
                            style: TextStyle(
                              fontSize: 10,
                              color: task.isOverdue ? AppColors.danger : AppColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Действия
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Редактировать'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppColors.danger),
                            SizedBox(width: 8),
                            Text('Удалить', style: TextStyle(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Метки
              if (task.labels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: task.labels.take(3).map((labelId) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLabelColor(labelId).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getLabelColor(labelId).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Метка $labelId',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getLabelColor(labelId),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLabelColor(int labelId) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.danger,
    ];
    return colors[labelId % colors.length];
  }
}
