import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity/connectivity_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/pin/pin_notifier.dart';
import 'router/app_router.dart';
import 'shared/widgets/offline_banner.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AppRouter.router.refresh();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        ref.read(pinNotifierProvider.notifier).lockForLaunch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: '어떤비용',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Column(
        children: [
          OfflineBanner(isOffline: !isOnline),
          Expanded(child: child ?? const SizedBox()),
        ],
      ),
    );
  }
}
