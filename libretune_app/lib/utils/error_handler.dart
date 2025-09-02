import 'package:flutter/material.dart';

class ErrorHandler {
  static void showSnackBar(BuildContext context, String message, {bool isError = true}) {
    final color = isError 
        ? Theme.of(context).colorScheme.error 
        : Theme.of(context).colorScheme.primary;
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  static Future<void> showErrorDialog(
    BuildContext context, 
    String title, 
    String message
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  static String formatError(Object error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception:', '').trim();
    }
    return 'An unexpected error occurred';
  }
}