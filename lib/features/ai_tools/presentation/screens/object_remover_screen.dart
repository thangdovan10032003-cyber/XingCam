import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:xingcam/core/widgets/privacy_secure_chip.dart';
import 'package:xingcam/features/ai_tools/presentation/widgets/before_after_slider.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/services/cvd_accessibility_service.dart';
import 'package:xingcam/features/ai_tools/domain/repositories/ai_tools_repository.dart';
import 'package:xingcam/features/ai_tools/domain/entities/editable_photo.dart';
import 'package:xingcam/features/ai_tools/domain/entities/removal_mask.dart';
import 'package:xingcam/core/injection/injection.dart';
import 'dart:ui' as ui;
import 'dart:io';

/// Full-screen inpainting workspace.
/// Users paint a white mask over objects they want removed,
/// then tap "Remove" to trigger the local SovereignInpaintâ„¢ engine.
class ObjectRemoverScreen extends StatefulWidget {
  final String imagePath;
  const ObjectRemoverScreen({super.key, required this.imagePath});

  @override
  State<ObjectRemoverScreen> createState() => _ObjectRemoverScreenState();
}

class _ObjectRemoverScreenState extends State<ObjectRemoverScreen> {
  final List<_BrushStroke> _strokes = [];
  _BrushStroke? _activeStroke;
  Offset? _lastPoint;
  DateTime? _lastPointTime;

  double _brushSize = 24.0;
  bool _isProcessing = false;
  String? _resultImagePath; // Path to AI-processed image
  bool _isMagicMode = false;
  Offset? _tapPulseCenter; // For Magic Tap Pulse

  final GlobalKey _maskKey = GlobalKey();

  // Used to bind canvas strictly to the image aspect ratio
  Size? _imageSize;
  bool _isLoadingSize = true;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final img = frameInfo.image;
      
      setState(() {
        _imageSize = Size(img.width.toDouble(), img.height.toDouble());
        _isLoadingSize = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSize = false;
      });
    }
  }

  // â”€â”€ Gesture handling â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _onPanStart(DragStartDetails d) {
    if (_isMagicMode) return;
    _lastPoint = d.localPosition;
    _lastPointTime = DateTime.now();
    final stroke = _BrushStroke(brushSize: _brushSize);
    stroke.points.add(d.localPosition);
    setState(() {
      _activeStroke = stroke;
      _strokes.add(stroke);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isMagicMode || _activeStroke == null) return;
    
    // Velocity Brush Logic (Phase 203)
    final now = DateTime.now();
    if (_lastPoint != null && _lastPointTime != null) {
      final distance = (d.localPosition - _lastPoint!).distance;
      final timeDelta = now.difference(_lastPointTime!).inMilliseconds;
      if (timeDelta > 0) {
        final velocity = distance / timeDelta; // px/ms
        // Dynamic scaling: fast = large brush, slow = narrow
        final targetSize = (_brushSize * 0.5) + (velocity * 15.0).clamp(0, _brushSize * 1.5);
        _activeStroke!.brushSize = (0.8 * _activeStroke!.brushSize + 0.2 * targetSize); // Smooth transition
      }
    }
    
    setState(() {
      _activeStroke?.points.add(d.localPosition);
      _lastPoint = d.localPosition;
      _lastPointTime = now;
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      _activeStroke = null;
      _lastPoint = null;
      _lastPointTime = null;
    });
  }

  void _onTapDown(TapDownDetails d) {
    if (!_isMagicMode) return;
    
    // Magic Tap with Visual Pulse (Phase 203)
    setState(() => _tapPulseCenter = d.localPosition);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _tapPulseCenter = null);
    });

    final stroke = _BrushStroke(brushSize: _brushSize * 3.0);
    stroke.points.add(d.localPosition);
    stroke.points.add(d.localPosition.translate(2, 2));
    
    setState(() {
      _strokes.add(stroke);
    });
    HapticsUtility.heavyImpact();
  }

  // â”€â”€ Mask export â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String?> _exportMask(Size canvasSize) async {
    // Render the mask canvas to a PNG
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = canvasSize;

    // Black background (keep area)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.background,
    );

    // White strokes (remove area) for export
    for (final stroke in _strokes) {
      _MaskPainter(
        strokes: [stroke],
        strokeColor: AppColors.textPrimary,
      ).paint(canvas, size);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final dir = Directory.systemTemp;
    final file = File('${dir.path}/mask_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> _onRemove() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('tools.magic_eraser.paint_hint'))),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Get rendered canvas size exactly covering the widget
    final renderBox = _maskKey.currentContext?.findRenderObject() as RenderBox?;
    final canvasSize = renderBox?.size ?? const Size(512, 512);

    final maskPath = await _exportMask(canvasSize);
    if (maskPath == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final repository = getIt<AiToolsRepository>();
    final result = await repository.removeObject(
      image: EditablePhoto(
        originalPath: widget.imagePath,
        width: canvasSize.width.toInt(),
        height: canvasSize.height.toInt(),
      ),
      mask: RemovalMask(
        maskPath: maskPath, 
        brushSize: 20.0,
      ),
    );

    result.fold(
      (failure) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sovereign Error: ${failure.message}')),
        );
      },
      (inpaintResult) {
        setState(() {
          _isProcessing = false;
          _resultImagePath = inpaintResult.resultImagePath;
        });

        HapticsUtility.leverWind();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('tools.magic_eraser.success')),
            backgroundColor: AppColors.accent,
          ),
        );
      },
    );
  }

  Future<void> _onSaveResult() async {
    if (_resultImagePath == null) return;
    try {
      await Gal.putImage(_resultImagePath!, album: 'XingCam AI');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('gallery.saved'))),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  CvdMode _cvdMode = CvdMode.none;
  final CvdAccessibilityService _cvdService = getIt<CvdAccessibilityService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _resultImagePath != null ? context.tr('tools.magic_eraser.compare') : context.tr('tools.magic_eraser.title'),
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.textSecondary),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.close, color: AppColors.textPrimary),
        ),
        actions: [
          PopupMenuButton<CvdMode>(
            icon: Icon(AppIcons.visibility, color: _cvdMode == CvdMode.none ? AppColors.textSecondary : AppColors.accent),
            onSelected: (mode) => setState(() => _cvdMode = mode),
            itemBuilder: (context) => [
              PopupMenuItem(value: CvdMode.none, child: Text(context.tr('common.done'))),
              PopupMenuItem(value: CvdMode.protanopia, child: Text(context.tr('tools.magic_eraser.accessibility.protanopia'))),
              PopupMenuItem(value: CvdMode.deuteranopia, child: Text(context.tr('tools.magic_eraser.accessibility.deuteranopia'))),
              PopupMenuItem(value: CvdMode.tritanopia, child: Text(context.tr('tools.magic_eraser.accessibility.tritanopia'))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: PrivacySecureChip()),
          ),
        ],
      ),
      body: Column(
        children: [
          // â”€â”€ Image + paint canvas (The Viewport) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: _isLoadingSize 
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : (_imageSize == null)
                    ? Center(child: Text(context.tr('tools.magic_eraser.load_error'), style: const TextStyle(color: AppColors.textPrimary)))
                    : Center(
                        child: Stack(
                          children: [
                            ColorFiltered(
                              colorFilter: _cvdMode == CvdMode.none 
                                ? const ColorFilter.mode(AppColors.transparent, BlendMode.multiply)
                                : ColorFilter.matrix(_cvdService.getMatrix(_cvdMode)!),
                              child: AspectRatio(
                                aspectRatio: _imageSize!.width / _imageSize!.height,
                                child: _resultImagePath != null
                                    ? BeforeAfterSlider(
                                        before: Image.file(File(widget.imagePath), fit: BoxFit.fill),
                                        after: Image.file(File(_resultImagePath!), fit: BoxFit.fill),
                                      )
                                    : GestureDetector(
                                        onTapDown: _onTapDown,
                                        onPanStart: (d) {
                                          if (!_isMagicMode) _onPanStart(d);
                                        },
                                        onPanUpdate: _isMagicMode ? null : _onPanUpdate,
                                        onPanEnd: _isMagicMode ? null : _onPanEnd,
                                        child: Stack(
                                          key: _maskKey,
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(File(widget.imagePath), fit: BoxFit.fill),
                                            CustomPaint(
                                              painter: _MaskPainter(
                                                strokes: _strokes,
                                                strokeColor: AppColors.accent.withValues(alpha: 0.5),
                                              ),
                                            ),
                                            // Magic Pulse Effect (Phase 203)
                                            if (_tapPulseCenter != null)
                                              Positioned(
                                                left: _tapPulseCenter!.dx - 30,
                                                top: _tapPulseCenter!.dy - 30,
                                                child: _PulseWave(),
                                              ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            if (_cvdMode != CvdMode.none)
                              Positioned(
                                top: 20,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withValues(alpha: 0.8),
                                    borderRadius: AppRadius.mdRadius,
                                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(AppIcons.info, color: AppColors.accent, size: 14),
                                      const SizedBox(width: 8),
                                      Text(
                                        _cvdService.getColorAssistLabel(skinToneHue: 0.1, warmth: 0.5, context: context),
                                        style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),

          // â”€â”€ ERGONOMIC BOTTOM CLUSTER (40% Thumb Range) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Brush Slider
                Row(
                  children: [
                    const Icon(AppIcons.brush, color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Slider(
                        value: _brushSize,
                        min: 8,
                        max: 80,
                        onChanged: (v) {
                          if (v.toInt() != _brushSize.toInt()) {
                            HapticsUtility.lightTick();
                          }
                          setState(() => _brushSize = v);
                        },
                      ),
                    ),
                    Text('${_brushSize.toInt()}px', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(width: AppSpacing.md),
                    // Magic Mode Toggle (Phase 194)
                    IconButton(
                      onPressed: () {
                        setState(() => _isMagicMode = !_isMagicMode);
                        HapticsUtility.dialClick();
                      },
                      icon: Icon(_isMagicMode ? AppIcons.ai : AppIcons.brush, color: _isMagicMode ? AppColors.accent : AppColors.textSecondary),
                      tooltip: 'Magic Select',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Row 2: Secondary Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _strokes.isEmpty ? null : () => setState(() => _strokes.removeLast()),
                      icon: const Icon(AppIcons.undo),
                      color: AppColors.textPrimary,
                    ),
                    IconButton(
                      onPressed: _strokes.isEmpty ? null : () => setState(() => _strokes.clear()),
                      icon: const Icon(AppIcons.clear),
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    if (_resultImagePath != null)
                      ElevatedButton.icon(
                        onPressed: _onSaveResult,
                        icon: const Icon(AppIcons.save, size: 18),
                        label: Text(context.tr('common.save'), style: const TextStyle(fontFamily: 'Outfit')),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Row 3: Primary Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing 
                        ? null 
                        : (_resultImagePath != null 
                            ? () => setState(() => _resultImagePath = null) 
                            : () async {
                                await _onRemove();
                              }),
                    child: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                        : Text(
                            (_resultImagePath != null ? context.tr('tools.magic_eraser.edit_again') : context.tr('tools.magic_eraser.remove')).toUpperCase(),
                            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
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

// â”€â”€ Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BrushStroke {
  double brushSize;
  final List<Offset> points = [];
  _BrushStroke({required this.brushSize});
}

// Phase 203: Magic Pulse Wave
class _PulseWave extends StatefulWidget {
  @override
  State<_PulseWave> createState() => _PulseWaveState();
}

class _PulseWaveState extends State<_PulseWave> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent.withValues(alpha: 1.0 - _ctrl.value), width: 2 + (4 * _ctrl.value)),
        ),
      ),
    );
  }
}

// â”€â”€ Painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MaskPainter extends CustomPainter {
  final List<_BrushStroke> strokes;
  final Color strokeColor;

  _MaskPainter({
    required this.strokes,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = strokeColor
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.brushSize
        ..style = PaintingStyle.stroke;

      if (stroke.points.length < 2) {
        // Single tap
        canvas.drawCircle(
          stroke.points.first,
          stroke.brushSize / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }

      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_MaskPainter old) =>
      old.strokes != strokes || old.strokeColor != strokeColor;
}






