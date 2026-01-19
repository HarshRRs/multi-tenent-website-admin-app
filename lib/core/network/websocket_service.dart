import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rockster/core/utils/secure_storage.dart';
import 'package:rockster/core/network/api_client.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketService {
  WebSocketChannel? _channel;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  final SecureStorage _secureStorage = SecureStorage();
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  bool _isOffline = false;
  
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  
  WebSocketStatus get status => _status;
  bool get isConnected => _status == WebSocketStatus.connected;

  // Update connectivity status from provider
  void updateNetworkStatus(bool isOffline) {
    if (_isOffline == isOffline) return;
    _isOffline = isOffline;
    
    if (isOffline) {
      disconnect(isManual: false);
    } else {
      // Reconnect immediately when back online
      _reconnectAttempts = 0;
      connect();
    }
  }

  Future<void> connect() async {
    if (_isOffline) return;
    if (_status == WebSocketStatus.connected || _status == WebSocketStatus.connecting) {
      return;
    }

    _status = WebSocketStatus.connecting;
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        _status = WebSocketStatus.disconnected; // Not error, just not authed
        return;
      }

      // Dynamic URL based on ApiClient
      final httpBase = ApiClient.baseUrl; 
      // Convert http(s) to ws(s)
      final wsBase = httpBase.replaceFirst('http', 'ws'); 
      final uri = Uri.parse('$wsBase/ws?token=$token');
      
      debugPrint('Connecting to WebSocket: $uri');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      _status = WebSocketStatus.connected;
      _reconnectAttempts = 0;
      _startHeartbeat();
      
      // Send initial handshake
      _sendMessage({'type': 'auth', 'token': token});
      debugPrint('WebSocket Connected');
      
    } catch (e) {
      debugPrint('WebSocket Connection Failed: $e');
      _status = WebSocketStatus.error;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      _eventController.add(data);
      
      if (data['type'] == 'pong') {
        return;
      }
    } catch (e) {
      // Invalid message format
    }
  }

  void _onError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _status = WebSocketStatus.error;
    _scheduleReconnect();
  }

  void _onDisconnected() {
    if (_status != WebSocketStatus.disconnected) {
       debugPrint('WebSocket Disconnected unexpectedly');
      _status = WebSocketStatus.disconnected;
      _heartbeatTimer?.cancel();
      _scheduleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isConnected) {
        _sendMessage({'type': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    if (_isOffline) return; 
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: 1 << _reconnectAttempts);
    _reconnectAttempts++;
    
    debugPrint('WebSocket: Retrying in ${delay.inSeconds}s (Attempt $_reconnectAttempts)');
    
    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  void subscribe(String channel) {
    if (!isConnected) return;
    _sendMessage({
      'type': 'subscribe',
      'channel': channel,
    });
  }

  void unsubscribe(String channel) {
    if (!isConnected) return;
    _sendMessage({
      'type': 'unsubscribe',
      'channel': channel,
    });
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        debugPrint('WebSocket Send Error: $e');
      }
    }
  }

  void disconnect({bool isManual = true}) {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    
    _status = WebSocketStatus.disconnected;
    // If manual disconnect (logout), don't reconnect
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
