import 'package:flutter/material.dart';

class CustomHeader_2 extends StatelessWidget {
  final String title;
  final Widget? leftAction;
  final Widget? rightAction;

  const CustomHeader_2({
    super.key,
    required this.title,
    this.leftAction,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        color: Colors.green,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (leftAction != null)
              Positioned(
                left: 20,
                bottom: 8,
                child: leftAction!,
              ),
            if (rightAction != null)
              Positioned(
                right: 20,
                bottom: 8,
                child: rightAction!,
              ),
          ],
        ),
      ),
    );
  }
}
