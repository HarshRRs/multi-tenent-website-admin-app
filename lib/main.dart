import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rockster/core/router/app_router.dart';
import 'package:rockster/core/theme/app_theme.dart';
import 'package:rockster/core/theme/theme_provider.dart';
import 'package:rockster/core/providers/messenger_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rockster/core/providers/locale_provider.dart';
import 'package:rockster/features/notifications/presentation/global_notification_listener.dart';
import 'package:rockster/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase background init failed: $e');
  }
  debugPrint('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase - app should still work
  }
  
  // Set up background message handler only if Firebase is initialized
  if (firebaseInitialized) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create high importance channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
        
    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );
  }
  
  // Enable edge-to-edge fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  // Request permissions on startup
  try {
    await _requestPermissions();
  } catch (e) {
    debugPrint('Permission request failed: $e');
  }
  
  // Initialize FCM only if Firebase is initialized
  if (firebaseInitialized) {
    try {
      await _initializeFCM();
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }
  
  runApp(
    const ProviderScope(
      child: GlobalNotificationListener(
        child: RocksterApp(),
      ),
    ),
  );
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

Future<void> _initializeFCM() async {
  final messaging = FirebaseMessaging.instance;
  
  // Request notification permission (iOS and Android 13+)
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  debugPrint('FCM Permission: ${settings.authorizationStatus}');
  
  // Get FCM token
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');
  
  // Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) {
    debugPrint('FCM Token refreshed: $newToken');
  });
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  });
}

class RocksterApp extends ConsumerWidget {
  const RocksterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Cosmos Admin',
      scaffoldMessengerKey: ref.watch(messengerKeyProvider),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
    );
  }
}
