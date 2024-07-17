[] Fetch audio
[] Visualize audio
[] Able to fetch and drag the audio sliders
[] get the timestamps of the audio
[] Play and pause the audio

class WaveformPainter extends CustomPainter {
final List<double> waveformData;
final double startTime;
final double endTime;

WaveformPainter(this.waveformData, this.startTime, this.endTime);

@override
void paint(Canvas canvas, Size size) {
final paint = Paint()
..color = Colors.blue
..style = PaintingStyle.stroke;

    final selectedPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final waveWidth = width / waveformData.length;

    for (int i = 0; i < waveformData.length - 1; i++) {
      final startX = i * waveWidth;
      final endX = (i + 1) * waveWidth;
      final startY = height - waveformData[i] / 255 * height;
      final endY = height - waveformData[i + 1] / 255 * height;

      final isSelected = startX / width >= startTime && endX / width <= endTime;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        isSelected ? selectedPaint : paint,
      );
    }

}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) {
return true;
}
}
