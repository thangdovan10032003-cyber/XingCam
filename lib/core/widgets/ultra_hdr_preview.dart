import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';

/// UltraHdrPreview: A high-dynamic-range rendering widget using Impeller.
/// Reconstructs True HDR radiance from an SDR base + Gain Map texture.
class UltraHdrPreview extends StatefulWidget {
  final Uint8List sdrBytes;
  final Uint8List gainMapBytes;
  final double maxBoost;

  const UltraHdrPreview({
    super.key,
    required this.sdrBytes,
    required this.gainMapBytes,
    this.maxBoost = 4.0,
  });

  @override
  State<UltraHdrPreview> createState() => _UltraHdrPreviewState();
}

class _UltraHdrPreviewState extends State<UltraHdrPreview> {
  ui.FragmentShader? _shader;
  ui.Image? _sdrImage;
  ui.Image? _gainMapImage;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final program = await ui.FragmentProgram.fromAsset('assets/shaders/ultra_hdr_shader.frag');
    final sdrCodec = await ui.instantiateImageCodec(widget.sdrBytes);
    final sdrFrame = await sdrCodec.getNextFrame();
    
    final gmCodec = await ui.instantiateImageCodec(widget.gainMapBytes);
    final gmFrame = await gmCodec.getNextFrame();

    if (mounted) {
      setState(() {
        _shader = program.fragmentShader();
        _sdrImage = sdrFrame.image;
        _gainMapImage = gmFrame.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null || _sdrImage == null || _gainMapImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomPaint(
      painter: _UltraHdrPainter(
        shader: _shader!,
        sdr: _sdrImage!,
        gainMap: _gainMapImage!,
        maxBoost: widget.maxBoost,
      ),
      size: Size(_sdrImage!.width.toDouble(), _sdrImage!.height.toDouble()),
    );
  }
}

class _UltraHdrPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image sdr;
  final ui.Image gainMap;
  final double maxBoost;

  _UltraHdrPainter({
    required this.shader,
    required this.sdr,
    required this.gainMap,
    required this.maxBoost,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setImageSampler(0, sdr);
    shader.setImageSampler(1, gainMap);
    shader.setFloat(2, maxBoost);
    shader.setFloat(3, 1.0); // Full HDR Mix

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
