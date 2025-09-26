import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';
import 'app_logger.dart';
import 'ui_notifier.dart';

final GetIt di = GetIt.instance;

/// Configure dependency injection container.
void setupDependencies() {
  // Talker singleton
  di.registerLazySingleton<Talker>(() => Talker());

  // AppLogger wraps Talker
  di.registerLazySingleton<AppLogger>(() => AppLogger(di<Talker>()));

  // UI notifier for user-friendly messages
  di.registerLazySingleton<UiNotifier>(() => const UiNotifier());
}

