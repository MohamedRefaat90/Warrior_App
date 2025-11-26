import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';

/// Educational screen explaining Nutri-Score, NOVA, and Eco-Score
class NutritionGuideScreen extends StatelessWidget {
  const NutritionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.understandingFoodScores),
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.makeBetterFoodChoices,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.learnAboutScores,
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
              title: context.l10n.nutriScoreLong,
              icon: Icons.favorite,
              iconColor: Colors.red,
              description: context.l10n.nutriScoreDescription,
              howItWorks: [
                context.l10n.nutriScorePoint1,
                context.l10n.nutriScorePoint2,
                context.l10n.nutriScorePoint3,
              ],
              scoreExamples: [
                _ScoreExample('A', Colors.green, context.l10n.excellentQuality,
                    context.l10n.scoreAExamples),
                _ScoreExample('B', Colors.lightGreen, context.l10n.goodQuality,
                    context.l10n.scoreBExamples),
                _ScoreExample('C', Colors.yellow, context.l10n.averageQuality,
                    context.l10n.scoreCExamples),
                _ScoreExample('D', Colors.orange, context.l10n.poorQuality,
                    context.l10n.scoreDExamples),
                _ScoreExample('E', Colors.red, context.l10n.veryPoorQuality,
                    context.l10n.scoreEExamples),
              ],
            ),

            Divider(height: 48, thickness: 2),

            // NOVA Group Section
            _buildScoreSection(
              context,
              title: context.l10n.novaClassification,
              icon: Icons.science,
              iconColor: Colors.blue,
              description: context.l10n.novaDescription,
              howItWorks: [
                context.l10n.novaGroup1,
                context.l10n.novaGroup2,
                context.l10n.novaGroup3,
                context.l10n.novaGroup4,
              ],
              scoreExamples: [
                _ScoreExample(
                    '1',
                    Colors.green,
                    context.l10n.unprocessedMinimal,
                    context.l10n.nova1Examples),
                _ScoreExample(
                    '2',
                    Colors.lightGreen,
                    context.l10n.culinaryIngredients,
                    context.l10n.nova2Examples),
                _ScoreExample('3', Colors.orange, context.l10n.processedFoods,
                    context.l10n.nova3Examples),
                _ScoreExample('4', Colors.red, context.l10n.ultraProcessed,
                    context.l10n.nova4Examples),
              ],
            ),

            Divider(height: 48, thickness: 2),

            // Eco-Score Section
            _buildScoreSection(
              context,
              title: context.l10n.ecoScore,
              icon: Icons.eco,
              iconColor: Colors.green,
              description: context.l10n.ecoScoreDescription,
              howItWorks: [
                context.l10n.ecoPoint1,
                context.l10n.ecoPoint2,
                context.l10n.ecoPoint3,
                context.l10n.ecoPoint4,
              ],
              scoreExamples: [
                _ScoreExample('A', Colors.green, context.l10n.veryLowImpact,
                    context.l10n.ecoAExamples),
                _ScoreExample('B', Colors.lightGreen, context.l10n.lowImpact,
                    context.l10n.ecoBExamples),
                _ScoreExample('C', Colors.yellow, context.l10n.moderateImpact,
                    context.l10n.ecoCExamples),
                _ScoreExample('D', Colors.orange, context.l10n.highImpact,
                    context.l10n.ecoDExamples),
                _ScoreExample('E', Colors.red, context.l10n.veryHighImpact,
                    context.l10n.ecoEExamples),
              ],
            ),

            // Tips Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
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
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.quickTips,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip(context, context.l10n.tip1),
                  _buildTip(context, context.l10n.tip2),
                  _buildTip(context, context.l10n.tip3),
                  _buildTip(context, context.l10n.tip4),
                  _buildTip(context, context.l10n.tip5),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, _ScoreExample example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: example.color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              example.score,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),

          // How it works
          Text(
            context.l10n.howItWorks,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...howItWorks.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Score examples
          Text(
            context.l10n.scoreGuide,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...scoreExamples.map((example) => _buildScoreCard(context, example)),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 24,
          ),
          const SizedBox(width: 8),
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
