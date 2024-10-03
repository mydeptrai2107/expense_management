import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0;

  // Danh sách các PageViewModel
  final List<PageViewModel> pages = [
    PageViewModel(
      title: tr('onboarding_title_1'),
      body: tr('onboarding_body_1'),
      image: Image.asset('assets/images/onboarding_1.png'),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        bodyTextStyle: TextStyle(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
      ),
    ),
    PageViewModel(
      title: tr('onboarding_title_2'),
      body: tr('onboarding_body_2'),
      image: Image.asset('assets/images/onboarding_2.png'),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        bodyTextStyle: TextStyle(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
      ),
    ),
    PageViewModel(
      title: tr('onboarding_title_3'),
      body: tr('onboarding_body_3'),
      image: Image.asset('assets/images/onboarding_3.png'),
      decoration: const PageDecoration(
        pageColor: Colors.white,
        bodyTextStyle: TextStyle(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: pages,
        done: Text(tr('onboarding_done'), style: TextStyle(color: Colors.black)),
        onDone: () => Navigator.pushReplacementNamed(context, '/login'),
        next: Text(tr('onboarding_next'), style: TextStyle(color: Colors.black)),
        skip: Text(tr('onboarding_skip'), style: TextStyle(color: Colors.black)),
        showSkipButton: true,
        onSkip: () => Navigator.pushReplacementNamed(context, '/login'),
        dotsDecorator: const DotsDecorator(
          color: Color(0xFFBDBDBD), // Màu sắc của dấu chấm
          activeColor: Colors.green, // Màu sắc của dấu chấm đang hoạt động
        ),
        onChange: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}