import 'package:flutter/material.dart';
import '../models/stage.dart';
import '../models/task.dart';
import 'task_card.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class StageColumn extends StatelessWidget {
  final Stage stage;
  final List<Task> tasks;
  final List<Stage> allStages;
  final Function(Task, Stage)? onTaskMoved;
  final Function(Task)? onTaskTap;
  final Function(Task)? onTaskEdit;
  final Function(Task)? onTaskDelete;
  final Function(int, int, int)? onTaskReordered;
  final VoidCallback? onAddTask;

  const StageColumn({
    super.key,
    required this.stage,
    required this.tasks,
    required this.allStages,
    this.onTaskMoved,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
    this.onTaskReordered,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileColumn(context),
      tablet: _buildTabletColumn(context),
      desktop: _buildDesktopColumn(context),
    );
  }

  Widget _buildMobileColumn(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumnHeader(context),
          _buildTasksList(context, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildTabletColumn(BuildContext context) {
    return Container(
      width: ResponsiveUtils.getKanbanColumnWidth(context),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumnHeader(context),
          Expanded(child: _buildTasksList(context)),
        ],
      ),
    );
  }

  Widget _buildDesktopColumn(BuildContext context) {
    return Container(
      width: ResponsiveUtils.getKanbanColumnWidth(context),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumnHeader(context),
          Expanded(child: _buildTasksList(context)),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context) {
    final color = _getStageColor(stage.name);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            stage.icon,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stage.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              '${tasks.length}',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, {bool isMobile = false}) {
    final content = Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: isMobile
            ? BorderRadius.circular(16)
            : const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
        border: Border.all(
          color: _getStageColor(stage.name).withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState()
                : isMobile
                ? _buildMobileTasksList(context)
                : _buildDesktopTasksList(context),
          ),
          _buildAddTaskArea(context),
        ],
      ),
    );

    return DragTarget<Task>(
      onWillAccept: (task) => task != null && task.stage != stage.id,
      onAccept: (task) {
        final targetStage = stage;
        onTaskMoved?.call(task, targetStage);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          foregroundDecoration: candidateData.isNotEmpty
              ? BoxDecoration(
                  border: Border.all(
                    color: _getStageColor(stage.name),
                    width: 2,
                  ),
                )
              : null,
          child: content,
        );
      },
    );
  }

  Widget _buildMobileTasksList(BuildContext context) {
    return Column(
      children: tasks.map((task) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          child: LongPressDraggable<Task>(
            data: task,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.85,
                child: TaskCard(task: task, onTap: null),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: TaskCard(
                key: ValueKey(task.id),
                task: task,
                onTap: () => onTaskTap?.call(task),
                onEdit: () => onTaskEdit?.call(task),
                onDelete: () => onTaskDelete?.call(task),
                onMove: () => _showMoveSheet(context, task),
              ),
            ),
            child: TaskCard(
              key: ValueKey(task.id),
              task: task,
              onTap: () => onTaskTap?.call(task),
              onEdit: () => onTaskEdit?.call(task),
              onDelete: () => onTaskDelete?.call(task),
              onMove: () => _showMoveSheet(context, task),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDesktopTasksList(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        onTaskReordered?.call(stage.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          key: ValueKey(task.id),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Draggable<Task>(
            data: task,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.05,
                child: Opacity(
                  opacity: 0.9,
                  child: TaskCard(task: task),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: TaskCard(
                task: task,
                onTap: () => onTaskTap?.call(task),
                onEdit: () => onTaskEdit?.call(task),
                onDelete: () => onTaskDelete?.call(task),
                onMove: () => _showMoveSheet(context, task),
                dragHandle: ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColors.textSecondary,
                    size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                  ),
                ),
              ),
            ),
            child: TaskCard(
              task: task,
              onTap: () => onTaskTap?.call(task),
              onEdit: () => onTaskEdit?.call(task),
              onDelete: () => onTaskDelete?.call(task),
              onMove: () => _showMoveSheet(context, task),
              dragHandle: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  color: AppColors.textSecondary,
                  size: ResponsiveUtils.getResponsiveFontSize(context, 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTaskArea(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        initiallyExpanded: false,
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, color: _getStageColor(stage.name)),
            const SizedBox(width: 8),
            Text(
              'Добавить задачу',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getStageColor(stage.name),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: onAddTask,
                  decoration: InputDecoration(hintText: 'Новая задача…'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Создать'),
              ),
            ],
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

  Future<void> _showMoveSheet(BuildContext context, Task task) async {
    final targets = allStages.where((s) => s.id != task.stage).toList();

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Переместить в этап')),
              for (final s in targets)
                ListTile(
                  leading: Text(s.icon, style: const TextStyle(fontSize: 18)),
                  title: Text(s.displayName),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onTaskMoved?.call(task, s);
                  },
                ),
            ],
          ),
        );
      },
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
