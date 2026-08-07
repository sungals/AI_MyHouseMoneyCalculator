import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity/connectivity_notifier.dart';
import 'core/notifications/firebase_push_service.dart';
import 'core/settings/locale_notifier.dart';
import 'core/settings/theme_mode_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_notifier.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/pin/pin_notifier.dart';
import 'l10n/gen/app_localizations.dart';
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
    Future.microtask(() {
      // Start push only if already authenticated (session restored from storage)
      final authState = ref.read(authNotifierProvider);
      if (authState is AppAuthAuthenticated) {
        ref.read(firebasePushServiceProvider).start();
      }
    });
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
        // 세션/PIN 상태가 바뀐 뒤 앱으로 돌아왔을 수 있으므로 redirect를 재평가한다.
        AppRouter.router.refresh();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // 백그라운드 진입 후 재개할 때 PIN/생체인증 게이트가 다시 동작하도록 잠근다.
        ref.read(pinNotifierProvider.notifier).lockForLaunch();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppAuthState>(authNotifierProvider, (previous, next) {
      final push = ref.read(firebasePushServiceProvider);
      if (next is AppAuthAuthenticated && previous is! AppAuthAuthenticated) {
        push.start();
      } else if (next is AppAuthUnauthenticated &&
          previous is AppAuthAuthenticated) {
        push.stop();
      }
    });

    final isOnline = ref.watch(connectivityProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kSupportedLocales,
      localeResolutionCallback: resolveLocale,
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
