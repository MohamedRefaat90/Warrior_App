import 'package:Warrior/core/extensions/string.dart';
import 'package:flutter/material.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            title.capitalizeWord(),
            style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle.capitalizeWord(),
            style: TextStyle(
                fontFamily: "poppins", fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
