import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bestie_tastes/home/index.dart';
import 'package:bestie_tastes/location/index.dart';
import 'package:bestie_tastes/wishlist/index.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  runApp(const MaterialApp(
    title: 'Bestie Tastes',
    debugShowCheckedModeBanner: false,
    home: MainWidget(),
  ));
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int pageIndex = 0;
  final pageController = PageController();

  List<Widget> get pages =>
      [const HomeWidget(), const LocationWidget(), const WishlistWidget()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          pageController.jumpToPage(value);
          setState(() {
            pageIndex = value;
          });
        },
        currentIndex: pageIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.houseChimney), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.mapLocationDot), label: 'Location'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidUser), label: 'Account'),
        ],
      ),
    );
  }
}
