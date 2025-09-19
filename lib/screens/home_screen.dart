import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/stage.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../widgets/stage_column.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача создана успешно'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка создания задачи: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача обновлена успешно'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка обновления задачи: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача удалена успешно'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления задачи: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _moveTaskToStage(Task task, Stage newStage) async {
    try {
      await _taskService.moveTaskToStage(task.id, newStage.id);
      await _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка перемещения задачи: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выхода: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  List<Task> _getTasksForStage(int stageId) {
    return _tasks.where((task) => task.stage == stageId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
              tooltip: 'Настройки',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Выйти',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки данных',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createTask,
            tooltip: 'Создать задачу',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            tooltip: 'Настройки',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgSecondary, AppColors.bgTertiary],
          ),
        ),
        child: SafeArea(
          child: _stages.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _stages.map((stage) {
                        final stageTasks = _getTasksForStage(stage.id);
                        return StageColumn(
                          stage: stage,
                          tasks: stageTasks,
                          onTaskMoved: _moveTaskToStage,
                          onTaskTap: (task) => _editTask(task),
                          onTaskEdit: _editTask,
                          onTaskDelete: _deleteTask,
                          onAddTask: () => _createTaskForStage(stage),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
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
            const Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: AppColors.gray600,
            ),
            const SizedBox(height: 16),
            Text(
              'Kanban Доска',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте первую задачу, чтобы начать работу',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createTask,
              icon: const Icon(Icons.add),
              label: const Text('Создать задачу'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTaskForStage(Stage stage) async {
    final result = await _showCreateTaskDialog(initialStage: stage);
    if (result != null) {
      try {
        await _taskService.createTask(
          name: result['name'] as String,
          description: result['description'] as String?,
          stage: stage.id,
        );
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача создана успешно'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка создания задачи: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _showCreateTaskDialog({
    Stage? initialStage,
  }) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Stage? selectedStage = initialStage ?? _stages.first;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать задачу'),
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
                value: selectedStage,
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
      ),
    );
  }

  Future<Map<String, dynamic>?> _showEditTaskDialog(Task task) async {
    final nameController = TextEditingController(text: task.name);
    final descriptionController = TextEditingController(text: task.description);
    Stage? selectedStage = _stages.firstWhere(
      (stage) => stage.id == task.stage,
      orElse: () => _stages.first,
    );

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать задачу'),
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
                value: selectedStage,
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
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Task task) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу'),
        content: Text('Вы уверены, что хотите удалить задачу "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
