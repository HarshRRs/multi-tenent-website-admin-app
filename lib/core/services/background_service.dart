import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background execution
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  // Init Notification Plugin in Background Isolate
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  // Service configuration
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Polling Timer
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Rockster Order Service",
          content: "Active & Listening for new orders...",
        );
      }
    }
    
    // Perform Polling
    await _checkNewOrders(flutterLocalNotificationsPlugin);
  });
}

Future<void> _checkNewOrders(FlutterLocalNotificationsPlugin notifs) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('last_order_check');
    final now = DateTime.now().toIso8601String();
    
    // Update check time immediately to avoid double alerts
    await prefs.setString('last_order_check', now);

    // Simple Dio Fetch - In real app, use the same BaseUrl logic or env vars
    // Just assuming localhost:3000 or the specific IP for Android Emulator (10.0.0.2)
    // IMPORTANT: Android Emulator needs 10.0.0.2 usually, but user is on Windows potentially running emulator or physical device?
    // User context says "phone app", implying real device or emulator. 
    // Secure approach: try multiple common hosts or just use the one configured.
    // Simplifying for this demo to assume standard localhost access (which might fail in emulator)
    // Ideally we should pass the base URL from the main isolate during init.
    
    final dio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:3000', // Standard Android Emulator host
        connectTimeout: const Duration(seconds: 5),
    )); 

    // Retrieve Orders
    // We would ideally fetch "orders created after $lastCheck"
    // Since our backend is simple mock-ish, let's just fetch all and filter locally
    final response = await dio.get('/orders');
    final List data = response.data;
    
    if (lastCheck == null) return; // First run, don't spam

    final lastCheckTime = DateTime.parse(lastCheck);
    
    final newOrders = data.where((o) {
        final createdAt = DateTime.tryParse(o['createdAt'] ?? '');
        return createdAt != null && createdAt.isAfter(lastCheckTime);
    }).toList();

    if (newOrders.isNotEmpty) {
      _showNotification(notifs, newOrders.length);
    }
  } catch (e) {
    print("Background Fetch Error: $e");
  }
}

Future<void> _showNotification(FlutterLocalNotificationsPlugin notifs, int count) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'orders_channel', 
    'Orders',
    channelDescription: 'Notifications for new restaurant orders',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      
  await notifs.show(
    0,
    'New Orders Received!',
    'You have $count new order(s) waiting.',
    platformChannelSpecifics,
    payload: 'orders',
  );
}

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Notification Channel setup for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'orders_channel', // id
      'Orders', // title
      description: 'This channel is used for order notifications.', // description
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'orders_channel',
        initialNotificationTitle: 'Rockster Service',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onStart, // Apple restricts this heavily.
      ),
    );

    service.startService();
  }
}
