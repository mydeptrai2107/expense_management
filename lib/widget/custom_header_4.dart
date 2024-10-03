import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomHeader_4 extends StatelessWidget {
  final String title;
  final void Function(String?) onTitleChanged;
  final Widget? leftAction;
  final Widget? rightAction;

  const CustomHeader_4({
    super.key,
    required this.title,
    required this.onTitleChanged,
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
            GestureDetector(
              onTap: () => _showTransactionTypeDialog(context),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
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

  void _showTransactionTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('select_transaction_type')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                      child: const Icon(FontAwesomeIcons.minus, color: Colors.white)),
                  title: Text(tr('expense')),
                  trailing: title == tr('expense')
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    onTitleChanged(tr('expense'));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green),
                      child: const Icon(FontAwesomeIcons.plus, color: Colors.white)),
                  title: Text(tr('income')),
                  trailing: title == tr('income')
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    onTitleChanged(tr('income'));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
