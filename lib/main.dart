import 'package:flutter/material.dart';
import 'package:bestie_tastes/home/index.dart';
import 'package:bestie_tastes/location/index.dart';
import 'package:bestie_tastes/wishlist/index.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Taste Atlas',
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
  final List<Widget> pages = [
    const HomeWidget(),
    const LocationWidget(),
    const WishlistWidget()
  ];

  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[
          SizedBox(
              width: 70,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ))
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        children: pages,
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_location), label: 'location'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'wishlist'),
        ],
      ),
    );
  }
}
