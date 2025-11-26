import 'package:flutter/material.dart';

/// Info section displaying important notes
class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 10),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _InfoBullet(
            text:
                'These calculations are based on the Mifflin-St Jeor equation',
          ),
          const SizedBox(height: 8),
          _InfoBullet(
            text:
                'Individual results may vary based on metabolism and genetics',
          ),
          const SizedBox(height: 8),
          _InfoBullet(
            text: 'Consult a healthcare professional before major diet changes',
          ),
          const SizedBox(height: 8),
          _InfoBullet(
            text: 'Track your progress and adjust as needed',
          ),
        ],
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade900,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
