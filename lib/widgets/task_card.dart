import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMove;
  final Widget? dragHandle; // shown on desktop to initiate reordering
  final Widget?
  crossColumnHandle; // shown on desktop to initiate cross-column drag

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onMove,
    this.dragHandle,
    this.crossColumnHandle,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileCard(context),
      tablet: _buildTabletCard(context),
      desktop: _buildDesktopCard(context),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isOverdue ? AppColors.danger : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeader(context, isMobile: true),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) _buildDescription(context),
              const SizedBox(height: 8),
              _buildMobileMetadata(context),
              if (task.labels.isNotEmpty) _buildLabels(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isOverdue ? AppColors.danger : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeader(context),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) _buildDescription(context),
              const SizedBox(height: 8),
              _buildMetadata(context),
              if (task.labels.isNotEmpty) _buildLabels(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isOverdue ? AppColors.danger : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeader(context),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) _buildDescription(context),
              const SizedBox(height: 8),
              _buildMetadata(context),
              if (task.labels.isNotEmpty) _buildLabels(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context, {bool isMobile = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            task.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: task.state
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              decoration: task.state ? TextDecoration.lineThrough : null,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
            maxLines: isMobile ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (task.state)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: ResponsiveUtils.getResponsiveFontSize(context, 20),
            ),
          ),
        if (crossColumnHandle != null) crossColumnHandle!,
        if (dragHandle != null) dragHandle!,
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      task.description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
      ),
      maxLines: ResponsiveUtils.isMobile(context) ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMobileMetadata(BuildContext context) {
    return Column(
      children: [
        if (task.deadline != null) _buildDeadline(context),
        const SizedBox(height: 8),
        _buildMobileActions(context),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        if (task.deadline != null) _buildDeadline(context),
        const Spacer(),
        _buildActions(context),
      ],
    );
  }

  Widget _buildDeadline(BuildContext context) {
    return Container(
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
            size: ResponsiveUtils.getResponsiveFontSize(context, 12),
            color: task.isOverdue ? AppColors.danger : AppColors.info,
          ),
          const SizedBox(width: 2),
          Text(
            task.deadlineFormatted,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
              color: task.isOverdue ? AppColors.danger : AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'move':
            onMove?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        items.add(
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  size: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Редактировать',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        // Show 'move' only on mobile; desktop/tablet use drag-and-drop
        if (ResponsiveUtils.isMobile(context)) {
          items.add(
            PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Переместить',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        items.add(
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete,
                  size: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Text(
                  'Удалить',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return items;
      },
      child: Icon(
        Icons.more_vert,
        size: ResponsiveUtils.getResponsiveFontSize(context, 16),
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit,
              size: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
            label: Text(
              'Редактировать',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: onMove,
            icon: Icon(
              Icons.swap_horiz,
              size: ResponsiveUtils.getResponsiveFontSize(context, 16),
            ),
            label: Text(
              'Переместить',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete,
              size: ResponsiveUtils.getResponsiveFontSize(context, 16),
              color: AppColors.danger,
            ),
            label: Text(
              'Удалить',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: task.labels
            .take(ResponsiveUtils.isMobile(context) ? 2 : 3)
            .map((labelId) {
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
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      10,
                    ),
                    color: _getLabelColor(labelId),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            })
            .toList(),
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
