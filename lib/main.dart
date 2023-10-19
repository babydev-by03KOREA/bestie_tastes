import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bestie_tastes/home/index.dart';
import 'package:bestie_tastes/location/index.dart';
import 'package:bestie_tastes/wishlist/index.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          height: 45.0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        actions: const <Widget>[],
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
