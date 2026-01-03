import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rockster/core/utils/secure_storage.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketService {
  static const String wsUrl = 'wss://api.rockster.com/ws'; // Replace with actual WebSocket URL
  
  WebSocketChannel? _channel;
  WebSocketStatus _status = WebSocketStatus.disconnected;
  final SecureStorage _secureStorage = SecureStorage();
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  
  WebSocketStatus get status => _status;
  bool get isConnected => _status == WebSocketStatus.connected;

  Future<void> connect() async {
    if (_status == WebSocketStatus.connected || _status == WebSocketStatus.connecting) {
      return;
    }

    _status = WebSocketStatus.connecting;
    
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) {
        _status = WebSocketStatus.error;
        return;
      }

      // Connect with auth token
      final uri = Uri.parse('$wsUrl?token=$token');
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
      
    } catch (e) {
      _status = WebSocketStatus.error;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      _eventController.add(data);
      
      // Handle heartbeat response
      if (data['type'] == 'pong') {
        // Heartbeat acknowledged
        return;
      }
    } catch (e) {
      // Invalid message format
    }
  }

  void _onError(dynamic error) {
    _status = WebSocketStatus.error;
    _scheduleReconnect();
  }

  void _onDisconnected() {
    _status = WebSocketStatus.disconnected;
    _heartbeatTimer?.cancel();
    _scheduleReconnect();
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
    if (_reconnectAttempts >= maxReconnectAttempts) {
      return; // Give up after max attempts
    }

    _reconnectTimer?.cancel();
    
    // Exponential backoff: 2^attempt seconds
    final delay = Duration(seconds: 1 << _reconnectAttempts);
    _reconnectAttempts++;
    
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
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _status = WebSocketStatus.disconnected;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
