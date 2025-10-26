import 'package:flutter/material.dart';
import '../repositories/workout_repository.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final repo = WorkoutRepository();
  Map<String, int> counts = {
    'Mon': 0,
    'Tue': 0,
    'Wed': 0,
    'Thu': 0,
    'Fri': 0,
    'Sat': 0,
    'Sun': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final c = await repo.getWorkoutsPerWeekday();
    setState(() {
      counts = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = counts.values.isEmpty
        ? 0
        : (counts.values.reduce((a, b) => a > b ? a : b));
    final chartMax = (maxVal < 3) ? 3 : maxVal;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Workouts Per Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _WorkoutBarChartPainter(
                      counts: counts,
                      days: days,
                      maxY: chartMax.toDouble(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Y axis = how many workouts you did that day'),
          ],
        ),
      ),
    );
  }
}

class _WorkoutBarChartPainter extends CustomPainter {
  final Map<String, int> counts;
  final List<String> days;
  final double maxY;

  _WorkoutBarChartPainter({
    required this.counts,
    required this.days,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final paintBar = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final leftPad = 40.0;
    final bottomPad = 40.0;
    final topPad = 20.0;
    final chartHeight = size.height - bottomPad - topPad;
    final chartWidth = size.width - leftPad - 20.0;

    final origin = Offset(leftPad, size.height - bottomPad);

    canvas.drawLine(
      Offset(origin.dx, origin.dy - chartHeight),
      origin,
      paintAxis,
    );

    canvas.drawLine(
      origin,
      Offset(origin.dx + chartWidth, origin.dy),
      paintAxis,
    );

    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    final tickCount = maxY.toInt();
    for (int i = 0; i <= tickCount; i++) {
      final yVal = origin.dy - (i / maxY) * chartHeight;
      canvas.drawLine(
        Offset(origin.dx - 5, yVal),
        Offset(origin.dx, yVal),
        paintAxis,
      );
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );
      textPainter.layout(minWidth: 0, maxWidth: leftPad - 8);
      textPainter.paint(
        canvas,
        Offset(
          origin.dx - 10 - textPainter.width,
          yVal - textPainter.height / 2,
        ),
      );
    }

    final barCount = days.length;
    final gap = 8.0;
    final totalGapSpace = gap * (barCount + 1);
    final usableW = chartWidth - totalGapSpace;
    final barW = usableW / barCount;

    for (int i = 0; i < barCount; i++) {
      final day = days[i];
      final value = counts[day] ?? 0;
      final barLeft = origin.dx + gap + i * (barW + gap);
      final barTop = origin.dy - (value / maxY) * chartHeight;
      final barRect = Rect.fromLTWH(barLeft, barTop, barW, origin.dy - barTop);
      canvas.drawRect(barRect, paintBar);

      final dayPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: day,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      );
      dayPainter.layout(minWidth: barW, maxWidth: barW + 20);
      dayPainter.paint(
        canvas,
        Offset(barLeft + (barW - dayPainter.width) / 2, origin.dy + 4),
      );
    }

    final yTitle = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'Workouts',
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
    yTitle.layout(minWidth: 0, maxWidth: leftPad);
    canvas.save();
    canvas.translate(8, size.height / 2);
    canvas.rotate(-3.14159 / 2);
    yTitle.paint(canvas, Offset(0, -yTitle.height / 2));
    canvas.restore();

    final xTitle = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: const TextSpan(
        text: 'Days',
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
    xTitle.layout(minWidth: 0, maxWidth: size.width);
    xTitle.paint(
      canvas,
      Offset(origin.dx + chartWidth / 2 - xTitle.width / 2, origin.dy + 20),
    );
  }

  @override
  bool shouldRepaint(covariant _WorkoutBarChartPainter oldDelegate) {
    return oldDelegate.counts != counts || oldDelegate.maxY != maxY;
  }
}
