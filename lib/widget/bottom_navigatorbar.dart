import 'package:expense_management/utils/language_notifier.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../view/home_screen.dart';
import '../view/statistics/statistics_screen.dart';
import '../view/transaction/create_transaction_screen.dart';
import '../view/transaction/transaction_history_screen.dart';
import '../view/user/profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionHistoryScreen(),
    const CreateTransactionScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ValueListenableBuilder<Locale>(
        valueListenable: languageNotifier,
        builder: (context, locale, child){
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.house),
                label: tr('home_label'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.list),
                label: tr('history_label'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.plus),
                label: tr('create_label'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.chartSimple),
                label: tr('statistics_label'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(FontAwesomeIcons.user),
                label: tr('profile_label'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          );
        },
      )
    );
  }
}
