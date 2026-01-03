import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/router/app_router.dart';
import 'package:rockster/core/theme/app_theme.dart';
import 'package:rockster/core/theme/theme_provider.dart';

import 'package:rockster/core/services/background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Background Service (Fire & Forget)
  BackgroundService.initializeService();
  
  runApp(const ProviderScope(child: RocksterApp()));
}

class RocksterApp extends ConsumerWidget {
  const RocksterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Rockster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
    );
  }
}
