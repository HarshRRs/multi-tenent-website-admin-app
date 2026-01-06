import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messengerKeyProvider = Provider((ref) => GlobalKey<ScaffoldMessengerState>());

extension MessengerExtension on WidgetRef {
  void showSnackBar(String message, {bool isError = true}) {
    read(messengerKeyProvider).currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
  }
}
