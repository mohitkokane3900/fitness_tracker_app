import 'package:flutter/material.dart';
import '../repositories/calorie_repository.dart';

// Shows total calories/macros for day/week/month + donut chart
class NutritionSummaryScreen extends StatefulWidget {
  const NutritionSummaryScreen({super.key});

  @override
  State<NutritionSummaryScreen> createState() => _NutritionSummaryScreenState();
}

class _NutritionSummaryScreenState extends State<NutritionSummaryScreen> {
  final repo = CalorieRepository();

  // which range we're showing: 'day', 'week', 'month'
  String mode = 'day';

  // totals to display
  int totalCalories = 0;
  double proteinG = 0;
  double fatG = 0;
  double carbsG = 0;

  @override
  void initState() {
    super.initState();
    _loadMode('day'); // default view
  }

  // Load the totals for a given mode and update UI
  Future<void> _loadMode(String newMode) async {
    Duration range;
    if (newMode == 'day') {
      range = const Duration(days: 1);
    } else if (newMode == 'week') {
      range = const Duration(days: 7);
    } else {
      range = const Duration(days: 30);
    }

    final totals = await repo.getTotalsByRange(range);

    final p = totals['protein'] ?? 0;
    final f = totals['fat'] ?? 0;
    final c = totals['carbs'] ?? 0;

    // If calories weren't logged, estimate from macros (4/4/9 rule)
    double calFromRepo = totals['cal'] ?? 0;
    if (calFromRepo <= 0) {
      calFromRepo = (p * 4) + (c * 4) + (f * 9);
    }

    setState(() {
      mode = newMode;
      proteinG = p;
      fatG = f;
      carbsG = c;
      totalCalories = calFromRepo.round();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Text label above the donut
    final labelText = mode == 'day'
        ? "Today"
        : mode == 'week'
        ? "This Week"
        : "This Month";

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Buttons to switch between Day / Week / Month
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _loadMode('day');
                  },
                  child: const Text('Day'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _loadMode('week');
                  },
                  child: const Text('Week'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _loadMode('month');
                  },
                  child: const Text('Month'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total calories text
            Text(
              '$labelText: $totalCalories Calories',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // Donut chart (CustomPaint draws it)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _MacroDonutPainter(
                      proteinG: proteinG,
                      fatG: fatG,
                      carbsG: carbsG,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Legend for donut colors
            _legendRow(
              color: const Color(0xFF5D1049),
              label: 'Protein',
              grams: proteinG,
            ),
            const SizedBox(height: 8),
            _legendRow(
              color: const Color(0xFF1B5E20),
              label: 'Carbs',
              grams: carbsG,
            ),
            const SizedBox(height: 8),
            _legendRow(
              color: const Color(0xFF1A237E),
              label: 'Fat',
              grams: fatG,
            ),
          ],
        ),
      ),
    );
  }

  // Small row: colored box + label + grams
  Widget _legendRow({
    required Color color,
    required String label,
    required double grams,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ${grams.toStringAsFixed(1)} g',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

// Painter that draws the donut chart for macros
class _MacroDonutPainter extends CustomPainter {
  final double proteinG;
  final double fatG;
  final double carbsG;

  _MacroDonutPainter({
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // d = diameter of the donut
    final d = size.shortestSide * 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: d, height: d);
    final radius = d / 2;

    // total macros so we can get percentages
    final total = proteinG + fatG + carbsG;

    // If no data, draw an empty grey ring
    if (total <= 0) {
      final bgPaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, bgPaint);

      final holePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.5, holePaint);
      return;
    }

    // Paints for each macro color
    final proteinPaint = Paint()
      ..color = const Color(0xFF5D1049)
      ..style = PaintingStyle.fill;
    final carbsPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;
    final fatPaint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.fill;

    // Start angle at top (-90 degrees-ish)
    double startAngle = -3.14159 / 2;

    // Protein slice
    final proteinSweep = (proteinG / total) * (3.14159 * 2);
    canvas.drawArc(rect, startAngle, proteinSweep, true, proteinPaint);
    startAngle += proteinSweep;

    // Carbs slice
    final carbsSweep = (carbsG / total) * (3.14159 * 2);
    canvas.drawArc(rect, startAngle, carbsSweep, true, carbsPaint);
    startAngle += carbsSweep;

    // Fat slice
    final fatSweep = (fatG / total) * (3.14159 * 2);
    canvas.drawArc(rect, startAngle, fatSweep, true, fatPaint);

    // Cut out the center to make a donut
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, holePaint);

    // The following code paints small text labels near each slice
    // (Protein / Carbs / Fat with grams)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: 'Protein\n${proteinG.toStringAsFixed(0)} g',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: radius * 0.9);

    canvas.save();
    canvas.translate(center.dx, center.dy - radius * 0.6);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();

    final textCarb = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textCarb.text = TextSpan(
      text: 'Carbs\n${carbsG.toStringAsFixed(0)} g',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    textCarb.layout(minWidth: 0, maxWidth: radius * 0.9);

    canvas.save();
    canvas.translate(center.dx + radius * 0.4, center.dy);
    textCarb.paint(canvas, Offset(-textCarb.width / 2, -textCarb.height / 2));
    canvas.restore();

    final textFat = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textFat.text = TextSpan(
      text: 'Fat\n${fatG.toStringAsFixed(0)} g',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    textFat.layout(minWidth: 0, maxWidth: radius * 0.9);

    canvas.save();
    canvas.translate(center.dx - radius * 0.4, center.dy);
    textFat.paint(canvas, Offset(-textFat.width / 2, -textFat.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MacroDonutPainter oldDelegate) {
    // Repaint when macro values change
    return oldDelegate.proteinG != proteinG ||
        oldDelegate.fatG != fatG ||
        oldDelegate.carbsG != carbsG;
  }
}
