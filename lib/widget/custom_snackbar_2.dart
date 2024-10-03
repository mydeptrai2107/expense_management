import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomSnackBar_2 {
  static Future<void> show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(FontAwesomeIcons.check, color: Colors.green),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
  }
}
