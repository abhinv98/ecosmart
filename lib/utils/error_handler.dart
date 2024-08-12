import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<T> wrapError<T>(
      Future<T> Function() function, BuildContext context) async {
    try {
      return await function();
    } catch (e) {
      showErrorDialog(context, e.toString());
      rethrow;
    }
  }
}
