import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity/connectivity_notifier.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'shared/widgets/offline_banner.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: '집돈계산기',
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
