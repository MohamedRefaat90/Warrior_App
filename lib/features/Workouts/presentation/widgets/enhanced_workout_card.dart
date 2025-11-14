import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/btn_loader.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EnhancedWorkoutCard extends ConsumerStatefulWidget {
  final WorkoutSetModel workout;
  final int index;
  final int? reorderIndex;

  const EnhancedWorkoutCard({
    super.key,
    required this.workout,
    required this.index,
    this.reorderIndex,
  });

  @override
  ConsumerState<EnhancedWorkoutCard> createState() =>
      _EnhancedWorkoutCardState();
}

class _EnhancedWorkoutCardState extends ConsumerState<EnhancedWorkoutCard>
    with SingleTickerProviderStateMixin {
  // Predefined vibrant colors for workout cards
  static final List<Color> _cardColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFFB71C1C), // Deep Red (Primary)
    const Color(0xFF1976D2), // Blue
  ];
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  late Color _cardColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTap: () {
            context.pushNamed(AppRouters.workoutDetails, extra: widget.workout);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.grey[900]!,
                        Colors.grey[850]!,
                      ]
                    : [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? _cardColor.withOpacity(0.3)
                      : Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: _isPressed ? 12 : 16,
                  offset: Offset(0, _isPressed ? 2 : 4),
                  spreadRadius: _isPressed ? 0 : 2,
                ),
                if (!isDark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(-2, -2),
                  ),
              ],
              border: Border.all(
                color: _isPressed
                    ? _cardColor.withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  // Accent gradient bar
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _cardColor,
                            _cardColor.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _cardColor,
                                _cardColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: _cardColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.workout.name!.capitalizeWord(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'poppins',
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.workout.description!.isEmpty
                                    ? 'No description'
                                    : widget.workout.description!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              // Exercise count badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _cardColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 14.sp,
                                      color: _cardColor,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${widget.workout.workoutItems!.length} exercises',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _cardColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        Column(
                          children: [
                            _buildActionButton(
                              icon: Icons.edit_rounded,
                              color: Colors.green,
                              onPressed: () => _showEditDialog(context),
                            ),
                            SizedBox(height: 8.h),
                            _buildActionButton(
                              icon: Icons.delete_rounded,
                              color: Colors.red,
                              onPressed: () => _showDeleteDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Generate consistent color based on workout ID
    _cardColor = _getCardColor();
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getCardColor() {
    // Simply use the index to ensure each card gets a different color
    // This guarantees no two adjacent cards will have the same color
    return _cardColors[widget.index % _cardColors.length];
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Delete ${widget.workout.name}',
                style: TextStyle(fontSize: 18.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this workout set? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) => ElevatedButton(
              onPressed: () async {
                ref
                    .read(workoutsProvider.notifier)
                    .deleteWorkoutSet(widget.workout.id!, widget.index);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: ref.watch(workoutsProvider).isLoading
                  ? BtnLoader(color: Colors.white)
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.workout.name);
    final descriptionController =
        TextEditingController(text: widget.workout.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: Colors.green,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            const Text('Edit Workout Set'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              textEditingController: nameController,
              isObscure: false,
              placeholderText: 'Workout Name',
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              textEditingController: descriptionController,
              isTextArea: true,
              isObscure: false,
              placeholderText: 'Description',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) => ElevatedButton(
              onPressed: () async {
                await ref.read(workoutsProvider.notifier).updateWorkoutSet(
                      widget.workout.copyWith(
                        name: nameController.text,
                        description: descriptionController.text,
                      ),
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: ref.watch(workoutsProvider).isLoading
                  ? BtnLoader(color: Colors.white)
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
