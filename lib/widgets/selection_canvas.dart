import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:iphipi/providers/audio_selection_provider.dart';

class SelectionCanvas extends StatefulWidget {
  @override
  _SelectionCanvasState createState() => _SelectionCanvasState();
}

class _SelectionCanvasState extends State<SelectionCanvas> {
  bool isDragging = false;
  bool isLeftMarkerSelected = false;
  bool isRightMarkerSelected = false;
  bool isRectSelected = false;
  final double rectMarkerWidth = 30.0;
  final double minRectWidth = 40.0; // Minimum width between the rods
  double dragStartX = 0.0; // Initial x position when dragging the rectangle

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioSelectionState>(
      builder: (context, state, child) {
        double startX = state.startX;
        double endX = state.endX;

        return GestureDetector(
          onPanStart: (details) {
            setState(() {
              if (_isLeftHandle(details.localPosition, startX, endX)) {
                isLeftMarkerSelected = true;
              } else if ((details.localPosition.dx > endX - rectMarkerWidth &&
                      details.localPosition.dx < endX + rectMarkerWidth) &&
                  endX != 0) {
                isRightMarkerSelected = true;
              } else if (details.localPosition.dx > startX &&
                  details.localPosition.dx < endX) {
                isRectSelected = true;
                dragStartX = details.localPosition.dx;
              } else {
                state.startX = details.localPosition.dx;
                state.endX = details.localPosition.dx + minRectWidth;
                isDragging = true;
              }
            });
          },
          onPanUpdate: (details) {
            setState(() {
              if (isDragging) {
                state.endX =
                    (details.localPosition.dx.clamp(0.0, context.size!.width))
                        .clamp(startX + minRectWidth, context.size!.width);
              } else if (isLeftMarkerSelected) {
                state.startX =
                    details.localPosition.dx.clamp(0.0, endX - minRectWidth);
              } else if (isRightMarkerSelected) {
                state.endX = details.localPosition.dx
                    .clamp(startX + minRectWidth, context.size!.width);
              } else if (isRectSelected) {
                double dx = details.localPosition.dx - dragStartX;
                double newStartX = startX + dx;
                double newEndX = endX + dx;
                if (newStartX >= 0.0 && newEndX <= context.size!.width) {
                  state.startX = newStartX;
                  state.endX = newEndX;
                  dragStartX =
                      details.localPosition.dx; // Update drag start position
                }
              }
            });
          },
          onPanEnd: (details) {
            setState(() {
              isDragging = false;
              isLeftMarkerSelected = false;
              isRightMarkerSelected = false;
              isRectSelected = false;
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                state.setCanvasWidth(constraints.maxWidth);
              });

              return CustomPaint(
                size: Size(constraints.maxWidth, 100), // Adjust size as needed
                painter: SelectionPainter(startX, endX),
              );
            },
          ),
        );
      },
    );
  }

  bool _isLeftHandle(Offset position, double startX, double endX) {
    return (position.dx > startX - rectMarkerWidth &&
        position.dx < startX + rectMarkerWidth &&
        endX >= 0);
  }
}

class SelectionPainter extends CustomPainter {
  final double startX;
  final double endX;

  SelectionPainter(this.startX, this.endX);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint rectPaint = Paint()..color = Colors.orange.withOpacity(0.2);
    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;
    final Paint handlePaint = Paint()..color = Colors.blue;

    if (startX != 0 && endX != 0) {
      // Draw the semi-transparent rectangle
      canvas.drawRect(
        Rect.fromPoints(
          Offset(startX, 0),
          Offset(endX, size.height),
        ),
        rectPaint,
      );

      // Draw the left handle
      canvas.drawCircle(Offset(startX, size.height / 2), 10, handlePaint);

      // Draw the right handle
      canvas.drawCircle(Offset(endX, size.height / 2), 10, handlePaint);

      // Draw lines at the start and end points
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX, size.height),
        linePaint,
      );
      canvas.drawLine(
        Offset(endX, 0),
        Offset(endX, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
