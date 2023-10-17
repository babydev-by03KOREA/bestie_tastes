import 'package:flutter/material.dart';

class WishlistWidget extends StatefulWidget {
  const WishlistWidget({super.key});

  @override
  State<WishlistWidget> createState() => _WishlistWidgetState();
}

class _WishlistWidgetState extends State<WishlistWidget> {
  // dismissible 밀어서 액션!
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Text('WishList Page')
      ),
    );
  }
}
