import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.0,
      height: 60.0,
      color: Colors.grey,
      child: Center(
        child: Text(
          item['act'][0], // Pierwsza litera tekstu
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Kolor tekstu w wstępnym obrazku
          ),
        ),
      ),
    );
  }
}
