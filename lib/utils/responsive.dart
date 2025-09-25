import 'package:flutter/material.dart';

/// Утилиты для адаптивного дизайна
class ResponsiveUtils {
  // Брейкпоинты для разных размеров экранов
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Определяет тип экрана на основе ширины
  static ScreenType getScreenType(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Определяет тип экрана на основе контекста
  static ScreenType getScreenTypeFromContext(BuildContext context) {
    return getScreenType(MediaQuery.of(context).size.width);
  }

  /// Проверяет, является ли экран мобильным
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Проверяет, является ли экран планшетом
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Проверяет, является ли экран десктопом
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Возвращает количество колонок для Kanban доски
  static int getKanbanColumns(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  /// Возвращает ширину колонки для Kanban доски
  static double getKanbanColumnWidth(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth - 32; // Полная ширина с отступами
      case ScreenType.tablet:
        return (screenWidth - 48) / 2; // Две колонки с отступами
      case ScreenType.desktop:
        return (screenWidth - 64) / 3; // Три колонки с отступами
      case ScreenType.largeDesktop:
        return (screenWidth - 80) / 4; // Четыре колонки с отступами
    }
  }

  /// Возвращает отступы для контента
  static EdgeInsets getContentPadding(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(32.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40.0);
    }
  }

  /// Возвращает размер шрифта в зависимости от экрана
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenType = getScreenTypeFromContext(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize * 0.9;
      case ScreenType.tablet:
        return baseFontSize;
      case ScreenType.desktop:
        return baseFontSize * 1.1;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.2;
    }
  }

  /// Возвращает количество элементов в строке для сетки
  static int getGridCrossAxisCount(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
      case ScreenType.largeDesktop:
        return 4;
    }
  }

  /// Возвращает отступы между элементами сетки
  static double getGridSpacing(BuildContext context) {
    final screenType = getScreenTypeFromContext(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 8.0;
      case ScreenType.tablet:
        return 12.0;
      case ScreenType.desktop:
        return 16.0;
      case ScreenType.largeDesktop:
        return 20.0;
    }
  }
}

/// Типы экранов
enum ScreenType { mobile, tablet, desktop, largeDesktop }

/// Виджет для адаптивного отображения контента
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenTypeFromContext(context);

    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Виджет для условного отображения на определенных экранах
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool showOnMobile;
  final bool showOnTablet;
  final bool showOnDesktop;
  final bool showOnLargeDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.showOnMobile = true,
    this.showOnTablet = true,
    this.showOnDesktop = true,
    this.showOnLargeDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenTypeFromContext(context);

    bool shouldShow = false;
    switch (screenType) {
      case ScreenType.mobile:
        shouldShow = showOnMobile;
        break;
      case ScreenType.tablet:
        shouldShow = showOnTablet;
        break;
      case ScreenType.desktop:
        shouldShow = showOnDesktop;
        break;
      case ScreenType.largeDesktop:
        shouldShow = showOnLargeDesktop;
        break;
    }

    return shouldShow ? child : const SizedBox.shrink();
  }
}

/// Виджет для адаптивного контейнера
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenTypeFromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double containerMaxWidth;
    switch (screenType) {
      case ScreenType.mobile:
        containerMaxWidth = screenWidth;
        break;
      case ScreenType.tablet:
        containerMaxWidth = screenWidth * 0.9;
        break;
      case ScreenType.desktop:
        containerMaxWidth = screenWidth * 0.8;
        break;
      case ScreenType.largeDesktop:
        containerMaxWidth = screenWidth * 0.7;
        break;
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth ?? containerMaxWidth),
      padding: padding ?? ResponsiveUtils.getContentPadding(context),
      margin: margin,
      child: child,
    );
  }
}
