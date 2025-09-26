import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/stage.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../widgets/stage_column.dart';
import '../widgets/responsive_navigation.dart';
import '../widgets/modern_dialog.dart';
import '../utils/responsive.dart';
import '../utils/animations.dart';
import '../theme/app_colors.dart';
import '../services/di.dart';
import '../services/app_logger.dart';
import '../services/ui_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  final AppLogger _logger = di<AppLogger>();
  final UiNotifier _notifier = di<UiNotifier>();

  List<Task> _tasks = [];
  List<Stage> _stages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Проверяем аутентификацию
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        throw Exception('Пользователь не аутентифицирован');
      }

      final stages = await _taskService.getStages();
      final tasks = await _taskService.getTasks();

      setState(() {
        _stages = stages;
        _tasks = tasks;
        _isLoading = false;
      });
      _logger.info(
        'home data loaded',
        payload: {'stages': stages.length, 'tasks': tasks.length},
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Улучшенная обработка ошибок
      if (e.toString().contains('DioException')) {
        if (e.toString().contains('connectionError')) {
          errorMessage =
              'Ошибка подключения к серверу. Проверьте адрес сервера и интернет-соединение.';
        } else if (e.toString().contains('connectionTimeout')) {
          errorMessage = 'Превышено время ожидания подключения к серверу.';
        } else if (e.toString().contains('receiveTimeout')) {
          errorMessage = 'Превышено время ожидания ответа от сервера.';
        } else if (e.toString().contains('sendTimeout')) {
          errorMessage = 'Превышено время отправки запроса на сервер.';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Сессия истекла. Пожалуйста, войдите заново.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Доступ запрещен. Проверьте права доступа.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Сервер не найден. Проверьте адрес сервера.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Внутренняя ошибка сервера. Попробуйте позже.';
        }
      } else if (e.toString().contains('Пользователь не аутентифицирован')) {
        errorMessage = 'Сессия истекла. Пожалуйста, войдите заново.';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      _logger.error('home load error', exception: e as Object?);
      if (mounted) {
        _notifier.showError(context, errorMessage);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _createTask() async {
    final result = await _showCreateTaskDialog();
    if (result != null) {
      try {
        await _taskService.createTask(
          name: result['name'] as String,
          description: result['description'] as String?,
          stage: result['stage'] as int?,
        );
        await _refreshData();
        if (mounted) {
          _notifier.showSuccess(context, 'Задача создана успешно');
        }
      } catch (e) {
        _logger.error('create task error', exception: e as Object?);
        if (mounted) _notifier.showError(context, 'Ошибка создания задачи');
      }
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await _showEditTaskDialog(task);
    if (result != null) {
      try {
        await _taskService.updateTask(
          taskId: task.id,
          name: result['name'] as String?,
          description: result['description'] as String?,
          stage: result['stage'] as int?,
          state: result['state'] as bool?,
        );
        await _refreshData();
        if (mounted) {
          _notifier.showSuccess(context, 'Задача обновлена успешно');
        }
      } catch (e) {
        await _refreshData();
        final updated = _tasks.any((t) => t.id == task.id);
        if (mounted) {
          if (updated) {
            _notifier.showSuccess(context, 'Задача обновлена');
          } else {
            _logger.error('update task error', exception: e as Object?);
            _notifier.showError(context, 'Ошибка обновления задачи');
          }
        }
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await _showDeleteConfirmation(task);
    if (confirmed == true) {
      try {
        await _taskService.deleteTask(task.id);
        await _refreshData();
        if (mounted) {
          _notifier.showSuccess(context, 'Задача удалена успешно');
        }
      } catch (e) {
        _logger.error('delete task error', exception: e as Object?);
        if (mounted) _notifier.showError(context, 'Ошибка удаления задачи');
      }
    }
  }

  Future<void> _moveTaskToStage(Task task, Stage newStage) async {
    final previousStageId = task.stage;

    // Optimistic update: сначала обновляем UI мгновенно
    final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      final updatedTask = task.copyWith(stage: newStage.id);

      setState(() {
        _tasks[taskIndex] = updatedTask;
      });
    }

    // Затем синхронизируем с сервером в фоне
    try {
      await _taskService.moveTaskToStage(task.id, newStage.id);
      // Успешно - показываем уведомление
      if (mounted && previousStageId != newStage.id) {
        _notifier.showSuccess(context, 'Задача перемещена');
      }
    } catch (e) {
      // Проверяем, не была ли задача все-таки перемещена на сервере
      final errorStr = e.toString();
      bool taskMayBeMoved =
          errorStr.contains('Ошибка парсинга ответа сервера') ||
          errorStr.contains('Пустой ответ сервера') ||
          errorStr.contains('Failed to fetch') ||
          errorStr.contains('ClientException');

      if (taskMayBeMoved) {
        // Если возможна проблема с парсингом или сетью, попробуем обновить данные
        try {
          await _refreshData();

          // Проверяем, действительно ли задача была перемещена
          final updatedTask = _tasks.firstWhere(
            (t) => t.id == task.id,
            orElse: () => task,
          );

          if (updatedTask.stage == newStage.id) {
            if (mounted) {
              _notifier.showSuccess(context, 'Задача перемещена успешно');
            }
            return; // Выходим, не откатывая изменения
          } else {}
        } catch (refreshError) {
          // Если обновление не удалось, продолжаем с откатом
        }
      }

      // Откат изменений при ошибке
      if (taskIndex != -1) {
        final revertedTask = task.copyWith(stage: previousStageId);

        setState(() {
          _tasks[taskIndex] = revertedTask;
        });
      }

      if (mounted) {
        // Улучшенное сообщение об ошибке
        String errorMessage = 'Ошибка перемещения задачи';

        if (errorStr.contains('Нет подключения к серверу')) {
          errorMessage =
              'Нет подключения к серверу. Проверьте интернет-соединение.';
        } else if (errorStr.contains('Сервер недоступен')) {
          errorMessage = 'Сервер недоступен. Попробуйте позже.';
        } else if (errorStr.contains('Ошибка парсинга ответа сервера')) {
          errorMessage =
              'Ошибка обработки ответа сервера. Задача может быть перемещена.';
        } else if (errorStr.contains('Пустой ответ сервера')) {
          errorMessage =
              'Сервер вернул пустой ответ. Задача может быть перемещена.';
        } else {
          errorMessage = 'Ошибка перемещения задачи. Попробуйте еще раз.';
        }

        _logger.error('move task ui error', exception: e as Object?);
        _notifier.showError(context, errorMessage);
      }
    }
  }

  Future<void> _reorderTaskInStage(
    int stageId,
    int oldIndex,
    int newIndex,
  ) async {
    final stageTasks = _getTasksForStage(stageId);
    if (oldIndex >= stageTasks.length || newIndex >= stageTasks.length) return;

    final task = stageTasks[oldIndex];
    final originalOrder = task.order;

    // Optimistic update: мгновенно обновляем порядок задач в UI
    final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      final updatedTask = task.copyWith(order: newIndex);

      setState(() {
        _tasks[taskIndex] = updatedTask;
      });
    }

    // Синхронизируем с сервером в фоне
    try {
      await _taskService.updateTaskOrder(task.id, newIndex);
      // Успешно - тихо завершаем (без уведомления для reorder)
    } catch (e) {
      // Откат изменений при ошибке
      if (taskIndex != -1) {
        final revertedTask = task.copyWith(order: originalOrder);

        setState(() {
          _tasks[taskIndex] = revertedTask;
        });
      }

      if (mounted) _notifier.showError(context, 'Ошибка изменения порядка');
      _logger.error('reorder task error', exception: e as Object?);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _logger.error('logout ui error', exception: e as Object?);
      if (mounted) _notifier.showError(context, 'Ошибка выхода');
    }
  }

  List<Task> _getTasksForStage(int stageId) {
    return _tasks.where((task) => task.stage == stageId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: ResponsiveAppBar(
          title: 'Task Manager',
          onSettings: () => Navigator.of(context).pushNamed('/settings'),
          onLogout: _handleLogout,
        ),
        body: Center(
          child: ModernAnimations.fadeScaleIn(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ModernLoadingIndicator(
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Загрузка задач...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: ResponsiveAppBar(
          title: 'Task Manager',
          onSettings: () => Navigator.of(context).pushNamed('/settings'),
          onLogout: _handleLogout,
        ),
        body: Center(
          child: ResponsiveContainer(
            child: ModernAnimations.fadeScaleIn(
              duration: ModernAnimations.slow,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModernAnimations.shake(
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ошибка загрузки данных',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ModernAnimations.fadeIn(
                        duration: ModernAnimations.slow,
                        child: ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Повторить'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ModernAnimations.fadeIn(
                        duration: ModernAnimations.slow,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings'),
                          child: const Text('Настройки'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Task Manager',
        onRefresh: _refreshData,
        onCreateTask: _createTask,
        onSettings: () => Navigator.of(context).pushNamed('/settings'),
        onLogout: _handleLogout,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.backgroundGradient,
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: _stages.isEmpty ? _buildEmptyState() : _buildKanbanBoard(),
        ),
      ),
      bottomNavigationBar: ResponsiveUtils.isMobile(context)
          ? ResponsiveNavigation(
              currentRoute: '/home',
              onRouteChanged: (route) {
                if (route == '/settings') {
                  Navigator.of(context).pushNamed('/settings');
                }
              },
              onLogout: _handleLogout,
              onRefresh: _refreshData,
              onCreateTask: _createTask,
            )
          : null,
    );
  }

  Widget _buildKanbanBoard() {
    return ResponsiveBuilder(
      mobile: _buildMobileKanban(),
      tablet: _buildTabletKanban(),
      desktop: _buildDesktopKanban(),
    );
  }

  Widget _buildMobileKanban() {
    return SingleChildScrollView(
      child: Column(
        children: _stages.map((stage) {
          final stageTasks = _getTasksForStage(stage.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: StageColumn(
              stage: stage,
              tasks: stageTasks,
              allStages: _stages,
              onTaskMoved: _moveTaskToStage,
              onTaskTap: (task) => _editTask(task),
              onTaskDelete: _deleteTask,
              onTaskReordered: _reorderTaskInStage,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabletKanban() {
    final basePadding = ResponsiveUtils.getContentPadding(context);
    final contentPadding = basePadding.copyWith(
      right: basePadding.right + 16.0,
    );
    final screenWidth = MediaQuery.of(context).size.width;
    const int cols = 2;
    final available = screenWidth - contentPadding.left - contentPadding.right;
    final double columnWidth =
        (available - (cols * 16.0)) / cols; // 16px суммарные отступы на колонку

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: contentPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _stages.map((stage) {
            final stageTasks = _getTasksForStage(stage.id);
            return Container(
              width: columnWidth,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StageColumn(
                stage: stage,
                tasks: stageTasks,
                allStages: _stages,
                onTaskMoved: _moveTaskToStage,
                onTaskTap: (task) => _editTask(task),
                onTaskDelete: _deleteTask,
                onTaskReordered: _reorderTaskInStage,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDesktopKanban() {
    final basePadding = ResponsiveUtils.getContentPadding(context);
    final contentPadding = basePadding.copyWith(
      right: basePadding.right + 16.0,
    );
    final screenType = ResponsiveUtils.getScreenTypeFromContext(context);
    final int cols = screenType == ScreenType.largeDesktop ? 4 : 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final available = screenWidth - contentPadding.left - contentPadding.right;
    final double columnWidth =
        (available - (cols * 16.0)) / cols; // 16px суммарные отступы на колонку

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: contentPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _stages.map((stage) {
            final stageTasks = _getTasksForStage(stage.id);
            return Container(
              width: columnWidth,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StageColumn(
                stage: stage,
                tasks: stageTasks,
                allStages: _stages,
                onTaskMoved: _moveTaskToStage,
                onTaskTap: (task) => _editTask(task),
                onTaskDelete: _deleteTask,
                onTaskReordered: _reorderTaskInStage,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ResponsiveContainer(
        child: ModernAnimations.fadeScaleIn(
          duration: ModernAnimations.slow,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ModernAnimations.pulse(
                child: const Icon(
                  Icons.dashboard_outlined,
                  size: 64,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Kanban Доска',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Создайте первую задачу, чтобы начать работу',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ModernAnimations.fadeIn(
                duration: ModernAnimations.verySlow,
                child: ElevatedButton.icon(
                  onPressed: _createTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Создать задачу'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showCreateTaskDialog({
    Stage? initialStage,
  }) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Stage? selectedStage = initialStage ?? _stages.first;

    return ModernDialogUtils.showModernDialog<Map<String, dynamic>>(
      context: context,
      title: 'Создать задачу',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Stage>(
              initialValue: selectedStage,
              decoration: const InputDecoration(
                labelText: 'Этап',
                border: OutlineInputBorder(),
              ),
              items: _stages.map((stage) {
                return DropdownMenuItem(
                  value: stage,
                  child: Text(stage.displayName),
                );
              }).toList(),
              onChanged: (stage) {
                selectedStage = stage;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop({
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                'stage': selectedStage?.id,
              });
            }
          },
          child: const Text('Создать'),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showEditTaskDialog(Task task) async {
    final nameController = TextEditingController(text: task.name);
    final descriptionController = TextEditingController(text: task.description);
    Stage? selectedStage = _stages.firstWhere(
      (stage) => stage.id == task.stage,
      orElse: () => _stages.first,
    );

    return ModernDialogUtils.showModernDialog<Map<String, dynamic>>(
      context: context,
      title: 'Редактировать задачу',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Stage>(
              initialValue: selectedStage,
              decoration: const InputDecoration(
                labelText: 'Этап',
                border: OutlineInputBorder(),
              ),
              items: _stages.map((stage) {
                return DropdownMenuItem(
                  value: stage,
                  child: Text(stage.displayName),
                );
              }).toList(),
              onChanged: (stage) {
                selectedStage = stage;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Задача выполнена'),
              value: task.state,
              onChanged: (value) {
                // Обновляем состояние в диалоге
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop({
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                'stage': selectedStage?.id,
                'state': task.state,
              });
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation(Task task) async {
    return ModernDialogUtils.showModernConfirmationDialog(
      context: context,
      title: 'Удалить задачу',
      message: 'Вы уверены, что хотите удалить задачу "${task.name}"?',
      confirmText: 'Удалить',
      cancelText: 'Отмена',
      confirmColor: AppColors.danger,
    );
  }
}
