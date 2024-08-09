import 'package:flutter/material.dart';
import 'dart:math';

class CustomColumnChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String unit;
  final double maxValue;

  const CustomColumnChart({
    super.key, 
    required this.values,
    required this.labels,
    required this.unit,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final minChartWidth = screenWidth;

    return SizedBox(
      height: 350,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                size: Size(
                  values.length * 100.0 > minChartWidth
                      ? values.length * 100.0
                      : minChartWidth,
                  300.0,
                ),
                painter: ColumnChartPainter(
                  values: values,
                  labels: labels,
                  unit: unit,
                  maxValue: maxValue,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Min: ${values.reduce(min)} $unit",
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                ),
                Text(
                  "Max: ${values.reduce(max)} $unit",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColumnChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final String unit;
  final double maxValue;

  ColumnChartPainter({
    required this.values,
    required this.labels,
    required this.unit,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint barPaint = Paint()
      ..color = const Color(0xFF0077F0)
      ..style = PaintingStyle.fill;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    const double barWidth = 50.0;
    const double padding = 50.0;
    final double maxBarHeight = size.height - 60.0;
    const double spaceFromStart = 20.0;

    // Desenha as colunas com os textos acima
    for (int i = 0; i < values.length; i++) {
      final double barHeight = (values[i] / maxValue) * maxBarHeight;
      final double left = spaceFromStart + i * (barWidth + padding);
      final double top = size.height - barHeight - 40;

      final RRect barRect = RRect.fromLTRBR(
        left,
        top,
        left + barWidth,
        size.height - 40,
        const Radius.circular(8),
      );
      canvas.drawRRect(barRect, barPaint);

      // Desenha os rótulos (datas) abaixo das barras
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas,
          Offset(left + (barWidth - labelPainter.width) / 2, size.height - 20));

      // Desenha os valores (quantidades) acima das barras
      final valueText = "${values[i]} $unit";
      final valuePainter = TextPainter(
        text: TextSpan(
          text: valueText,
          style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(
          canvas,
          Offset(left + (barWidth - valuePainter.width) / 2,
              top - valuePainter.height - 5));
    }

    // Desenha linhas de grade pontilhadas manualmente
    const double dashWidth = 4;
    const double dashSpace = 4;

    const int numberOfTicks = 5;
    final double tickSpacing = maxBarHeight / (numberOfTicks - 1);

    for (int i = 0; i <= numberOfTicks; i++) {
      const double x =
          spaceFromStart - dashSpace; // Posição X ajustada para o lado esquerdo
      final double y = size.height - 40 - (i * tickSpacing);
      _drawDashedLine(canvas, Offset(x, y), Offset(size.width, y), dashWidth,
          dashSpace, gridPaint);
    }

    // Adiciona o tipo de dado ao lado esquerdo do gráfico
    final unitPainter = TextPainter(
      text: TextSpan(
        text: unit,
        style: textStyle.copyWith(color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    unitPainter.paint(canvas, Offset(-unitPainter.width - 10, size.height / 2));
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end,
      double dashWidth, double dashSpace, Paint paint) {
    final double distance = (start - end).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    double currentOffset = 0;

    for (int i = 0; i < dashCount; i++) {
      final double x1 =
          start.dx + currentOffset * (end.dx - start.dx) / distance;
      final double y1 =
          start.dy + currentOffset * (end.dy - start.dy) / distance;
      final double x2 = x1 + dashWidth * (end.dx - start.dx) / distance;
      final double y2 = y1 + dashWidth * (end.dy - start.dy) / distance;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      currentOffset += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
