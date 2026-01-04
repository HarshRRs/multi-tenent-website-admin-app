import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rockster/core/router/app_router.dart';
import 'package:rockster/core/theme/app_theme.dart';
import 'package:rockster/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable edge-to-edge fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  // Request permissions on startup
  await _requestPermissions();
  
  runApp(const ProviderScope(child: RocksterApp()));
}

Future<void> _requestPermissions() async {
  // Request multiple permissions at once
  await [
    Permission.camera,
    Permission.storage,
    Permission.photos,
    Permission.notification,
  ].request();
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
