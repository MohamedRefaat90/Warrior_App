import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Info section displaying important notes
class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15.r),
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
              Icon(Icons.info_outline, color: Colors.blue, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _InfoBullet(
            text:
                'These calculations are based on the Mifflin-St Jeor equation',
          ),
          SizedBox(height: 8.h),
          _InfoBullet(
            text:
                'Individual results may vary based on metabolism and genetics',
          ),
          SizedBox(height: 8.h),
          _InfoBullet(
            text: 'Consult a healthcare professional before major diet changes',
          ),
          SizedBox(height: 8.h),
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
          padding: EdgeInsets.only(top: 6.h, right: 8.w),
          child: Container(
            width: 6.w,
            height: 6.h,
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
              fontSize: 13.sp,
              color: Colors.blue.shade900,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
