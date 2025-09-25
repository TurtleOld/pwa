import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskCard({super.key, required this.task, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileCard(context),
      tablet: _buildTabletCard(context),
      desktop: _buildDesktopCard(context),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isOverdue
              ? AppColors.danger.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: ModernShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(context, isMobile: true),
                const SizedBox(height: 12),
                if (task.description.isNotEmpty) _buildDescription(context),
                const SizedBox(height: 12),
                _buildMobileMetadata(context),
                if (task.labels.isNotEmpty) _buildLabels(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isOverdue
              ? AppColors.danger.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: ModernShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(context),
                const SizedBox(height: 12),
                if (task.description.isNotEmpty) _buildDescription(context),
                const SizedBox(height: 12),
                _buildMetadata(context),
                if (task.labels.isNotEmpty) _buildLabels(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isOverdue
              ? AppColors.danger.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: ModernShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskHeader(context),
                const SizedBox(height: 12),
                if (task.description.isNotEmpty) _buildDescription(context),
                const SizedBox(height: 12),
                _buildMetadata(context),
                if (task.labels.isNotEmpty) _buildLabels(context),
              ],
            ),
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
    return IconButton(
      onPressed: onDelete,
      icon: Icon(
        Icons.delete_outline,
        size: ResponsiveUtils.getResponsiveFontSize(context, 20),
        color: AppColors.danger,
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.danger.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: onDelete,
        icon: Icon(
          Icons.delete_outline,
          size: ResponsiveUtils.getResponsiveFontSize(context, 24),
          color: AppColors.danger,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.danger.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
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
