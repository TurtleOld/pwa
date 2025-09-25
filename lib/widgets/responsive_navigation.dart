import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Адаптивная навигация для PWA
class ResponsiveNavigation extends StatelessWidget {
  final String currentRoute;
  final Function(String) onRouteChanged;
  final VoidCallback? onLogout;
  final VoidCallback? onRefresh;
  final VoidCallback? onCreateTask;

  const ResponsiveNavigation({
    super.key,
    required this.currentRoute,
    required this.onRouteChanged,
    this.onLogout,
    this.onRefresh,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileNavigation(context),
      tablet: _buildTabletNavigation(context),
      desktop: _buildDesktopNavigation(context),
    );
  }

  /// Мобильная навигация (Bottom Navigation Bar)
  Widget _buildMobileNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(),
      onTap: (index) => _onTabTapped(context, index),
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Доска'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Создать'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Выход'),
      ],
    );
  }

  /// Планшетная навигация (AppBar с кнопками)
  Widget _buildTabletNavigation(BuildContext context) {
    return AppBar(
      title: const Text('Task Manager'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Обновить',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onCreateTask,
          tooltip: 'Создать задачу',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => onRouteChanged('/settings'),
          tooltip: 'Настройки',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Выйти',
        ),
      ],
    );
  }

  /// Десктопная навигация (AppBar с кнопками и дополнительными элементами)
  Widget _buildDesktopNavigation(BuildContext context) {
    return AppBar(
      title: const Text('Task Manager'),
      centerTitle: false,
      actions: [
        // Поиск (для десктопа)
        ResponsiveVisibility(
          showOnDesktop: true,
          showOnLargeDesktop: true,
          child: Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск задач...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Обновить',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onCreateTask,
          tooltip: 'Создать задачу',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => onRouteChanged('/settings'),
          tooltip: 'Настройки',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Выйти',
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  int _getCurrentIndex() {
    switch (currentRoute) {
      case '/home':
        return 0;
      case '/create':
        return 1;
      case '/settings':
        return 2;
      case '/logout':
        return 3;
      default:
        return 0;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        onRouteChanged('/home');
        break;
      case 1:
        onCreateTask?.call();
        break;
      case 2:
        onRouteChanged('/settings');
        break;
      case 3:
        onLogout?.call();
        break;
    }
  }
}

/// Адаптивный AppBar для экранов
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onRefresh;
  final VoidCallback? onCreateTask;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.onRefresh,
    this.onCreateTask,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileAppBar(context),
      tablet: _buildTabletAppBar(context),
      desktop: _buildDesktopAppBar(context),
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Обновить',
          ),
        if (onCreateTask != null)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onCreateTask,
            tooltip: 'Создать задачу',
          ),
        if (onSettings != null)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettings,
            tooltip: 'Настройки',
          ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Выйти',
          ),
      ],
    );
  }

  Widget _buildTabletAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Обновить',
          ),
        if (onCreateTask != null)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onCreateTask,
            tooltip: 'Создать задачу',
          ),
        if (onSettings != null)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettings,
            tooltip: 'Настройки',
          ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Выйти',
          ),
      ],
    );
  }

  Widget _buildDesktopAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      leading: leading,
      actions: [
        // Поиск для десктопа
        ResponsiveVisibility(
          showOnDesktop: true,
          showOnLargeDesktop: true,
          child: Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск задач...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Обновить',
          ),
        if (onCreateTask != null)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onCreateTask,
            tooltip: 'Создать задачу',
          ),
        if (onSettings != null)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettings,
            tooltip: 'Настройки',
          ),
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: 'Выйти',
          ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
