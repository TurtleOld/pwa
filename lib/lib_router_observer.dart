import 'package:flutter/widgets.dart';
import 'services/di.dart';
import 'services/app_logger.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final AppLogger _logger = di<AppLogger>();

  void _log(String event, Route<dynamic>? route) {
    final name = (route is PageRoute) ? route.settings.name ?? '<unnamed>' : '<non-page>';
    _logger.info('route $event', payload: {'name': name});
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('replace', newRoute);
  }
}

