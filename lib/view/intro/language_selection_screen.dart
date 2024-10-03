import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/widget/custom_header_2.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader_2(title: 'Select Language'),
          Spacer(),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.setLocale(const Locale('en'));
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey[300]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/english_flag.png',
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 8),
                        Text('English', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.setLocale(const Locale('vi'));
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[300]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/vietnamese_flag.png',
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 8),
                        Text('Vietnamese', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
