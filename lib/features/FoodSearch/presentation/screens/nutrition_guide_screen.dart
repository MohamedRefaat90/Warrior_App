import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Educational screen explaining Nutri-Score, NOVA, and Eco-Score
class NutritionGuideScreen extends StatelessWidget {
  const NutritionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Understanding Food Scores'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  16.verticalSpace,
                  Text(
                    'Make Better Food Choices',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  8.verticalSpace,
                  Text(
                    'Learn about the scores that help you understand food quality',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Nutri-Score Section
            _buildScoreSection(
              context,
              title: 'Nutri-Score',
              icon: Icons.favorite,
              iconColor: Colors.red,
              description:
                  'A nutrition quality indicator that rates foods from A (best) to E (worst) based on their nutritional value.',
              howItWorks: [
                'Considers positive nutrients: fiber, protein, fruits & vegetables',
                'Considers negative nutrients: calories, saturated fat, sugar, salt',
                'The balance determines the final score',
              ],
              scoreExamples: [
                _ScoreExample('A', Colors.green, 'Excellent nutritional quality',
                    'Vegetables, fruits, whole grains'),
                _ScoreExample('B', Colors.lightGreen,
                    'Good nutritional quality', 'Yogurt, fish, nuts'),
                _ScoreExample('C', Colors.yellow, 'Average nutritional quality',
                    'Bread, pasta, some cereals'),
                _ScoreExample('D', Colors.orange, 'Poor nutritional quality',
                    'Cookies, cakes, processed foods'),
                _ScoreExample('E', Colors.red, 'Very poor nutritional quality',
                    'Soft drinks, chips, candy'),
              ],
            ),

            Divider(height: 48.h, thickness: 2),

            // NOVA Group Section
            _buildScoreSection(
              context,
              title: 'NOVA Classification',
              icon: Icons.science,
              iconColor: Colors.blue,
              description:
                  'A food classification system based on the extent and purpose of food processing.',
              howItWorks: [
                'Group 1: Unprocessed or minimally processed foods',
                'Group 2: Processed culinary ingredients',
                'Group 3: Processed foods',
                'Group 4: Ultra-processed foods',
              ],
              scoreExamples: [
                _ScoreExample('1', Colors.green, 'Unprocessed/Minimally',
                    'Fresh fruits, vegetables, meat, eggs'),
                _ScoreExample('2', Colors.lightGreen, 'Culinary Ingredients',
                    'Oils, butter, sugar, salt'),
                _ScoreExample('3', Colors.orange, 'Processed Foods',
                    'Canned vegetables, cheese, bread'),
                _ScoreExample('4', Colors.red, 'Ultra-Processed',
                    'Soft drinks, instant noodles, packaged snacks'),
              ],
            ),

            Divider(height: 48.h, thickness: 2),

            // Eco-Score Section
            _buildScoreSection(
              context,
              title: 'Eco-Score',
              icon: Icons.eco,
              iconColor: Colors.green,
              description:
                  'An environmental impact indicator that rates foods from A (best) to E (worst) based on their ecological footprint.',
              howItWorks: [
                'Considers production methods and origin',
                'Evaluates transportation and packaging',
                'Accounts for environmental policies',
                'Measures carbon footprint and biodiversity impact',
              ],
              scoreExamples: [
                _ScoreExample('A', Colors.green, 'Very low environmental impact',
                    'Local organic vegetables'),
                _ScoreExample('B', Colors.lightGreen,
                    'Low environmental impact', 'Seasonal fruits, legumes'),
                _ScoreExample('C', Colors.yellow, 'Moderate environmental impact',
                    'Dairy products, poultry'),
                _ScoreExample('D', Colors.orange, 'High environmental impact',
                    'Imported foods, red meat'),
                _ScoreExample('E', Colors.red, 'Very high environmental impact',
                    'Air-freighted foods, intensive farming'),
              ],
            ),

            // Tips Section
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      12.horizontalSpace,
                      Text(
                        'Quick Tips',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                      ),
                    ],
                  ),
                  16.verticalSpace,
                  _buildTip(context, 'Aim for Nutri-Score A or B products'),
                  _buildTip(context, 'Choose NOVA Group 1 or 2 when possible'),
                  _buildTip(context, 'Prefer Eco-Score A or B for the planet'),
                  _buildTip(context,
                      'Read ingredient lists, not just scores'),
                  _buildTip(context,
                      'Balance is key - variety in your diet matters'),
                ],
              ),
            ),

            32.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required List<String> howItWorks,
    required List<_ScoreExample> scoreExamples,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32.w),
              ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          16.verticalSpace,

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
          24.verticalSpace,

          // How it works
          Text(
            'How it works:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          12.verticalSpace,
          ...howItWorks.map((point) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20.w,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          24.verticalSpace,

          // Score examples
          Text(
            'Score Guide:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          16.verticalSpace,
          ...scoreExamples.map((example) => _buildScoreCard(context, example)),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, _ScoreExample example) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: example.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: example.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Score badge
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: example.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              example.score,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  example.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                4.verticalSpace,
                Text(
                  example.examples,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 24.w,
          ),
          8.horizontalSpace,
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreExample {
  final String score;
  final Color color;
  final String label;
  final String examples;

  _ScoreExample(this.score, this.color, this.label, this.examples);
}

