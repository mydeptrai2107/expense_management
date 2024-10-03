import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomHeader_6 extends StatelessWidget {
  final String title;
  final void Function(String?) onTitleChanged;
  final Widget? leftAction;
  final Widget? rightAction;
  final bool isSearching;
  final Function(String)? onSearchChanged;
  final VoidCallback onSearchClose;

  const CustomHeader_6({
    super.key,
    required this.title,
    required this.onTitleChanged,
    this.leftAction,
    this.rightAction,
    this.isSearching = false,
    this.onSearchChanged,
    required this.onSearchClose,
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
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (leftAction != null) leftAction!,
            Expanded(
              child: Center(
                child: isSearching
                    ? TextField(
                        onChanged: onSearchChanged,
                        decoration:  InputDecoration(
                          hintText: tr('search'),
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _showTransactionTypeDialog(context),
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
            ),
            if (isSearching)
              GestureDetector(
                onTap: onSearchClose,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            if (rightAction != null) rightAction!,
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
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
                  ),
                  title: Text(tr('income')),
                  trailing: title == 'income'
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    onTitleChanged(tr('income'));
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(FontAwesomeIcons.minus, color: Colors.white),
                  ),
                  title: Text(tr('expense')),
                  trailing: title == tr('expense')
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    onTitleChanged(tr('expense'));
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
