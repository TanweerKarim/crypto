import 'package:crypto_app/auth/logout.dart';
import 'package:floating_navbar/floating_navbar.dart';
import 'package:floating_navbar/floating_navbar_item.dart';
import 'package:flutter/material.dart';
import 'anotherPage.dart';
import 'home.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Home(),
        bottomNavigationBar: FloatingNavBar(
          resizeToAvoidBottomInset: false,
          color: Color.fromARGB(226, 104, 102, 102),
          items: [
            FloatingNavBarItem(
              iconData: Icons.home,
              title: 'Home',
              page: Home(),
            ),
            FloatingNavBarItem(
              iconData: Icons.account_circle,
              title: 'Account',
              page: LogoutScreen(),
            )
          ],
          selectedIconColor: Colors.white,
          hapticFeedback: true,
          horizontalPadding: 40,
        ),
      ),
    );
  }
}
