import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/widgets/tutorial_overlay.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';

class ZineEditorScreen extends StatefulWidget {
  const ZineEditorScreen({super.key});

  @override
  State<ZineEditorScreen> createState() => _ZineEditorScreenState();
}

class _ZineEditorScreenState extends State<ZineEditorScreen> {
  final List<Offset> _positions = [
    const Offset(40, 60),
    const Offset(180, 240),
    const Offset(60, 420),
  ];
  
  final List<double> _rotations = [0.1, -0.05, 0.08];
  final List<bool> _isLive = [false, true, false]; 
  int _selectedIndex = 0;

  void _generateAutoLayout() {
    setState(() {
      for (int i = 0; i < _positions.length; i++) {
        _positions[i] = Offset(20.0 + (i * 20), 40.0 + (i * 100));
        _rotations[i] = 0.0;
      }
    });
    HapticsUtility.leverWind();
  }

  void _addPhoto() {
    setState(() {
      _positions.add(const Offset(100, 100));
      _rotations.add(0.0);
      _isLive.add(false);
      _selectedIndex = _positions.length - 1;
    });
    HapticsUtility.dialClick();
  }

  void _updateRotation(double delta) {
    setState(() {
      final oldRotation = _rotations[_selectedIndex];
      _rotations[_selectedIndex] += delta;
      
      // Haptic Snapping (Phase 196)
      // Snap to 0, PI/2, PI, 1.5PI
      final rad = _rotations[_selectedIndex];
      const quarter = 3.14159 / 2;
      for (int i = -4; i <= 4; i++) {
        final target = i * quarter;
        if ((rad - target).abs() < 0.05) {
          _rotations[_selectedIndex] = target;
          if ((oldRotation - target).abs() >= 0.05) {
            HapticsUtility.heavyImpact();
          }
          break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TutorialOverlay.show(
        context,
        title: 'XingCam Zine Editor',
        description: 'Create magazine-style editorials. Drag, rotate, and scale your photos on the canvas to tell a visual story.',
        icon: AppIcons.stories,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper, // Paper-like color
      appBar: AppBar(
        title: Text(context.tr('zine.title'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.background, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.close, color: AppColors.background),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.tr('zine.render'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.background, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Paper Grain Overlay â€” sovereign, offline, no network.
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  painter: _PaperGrainPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          
          // Canvas Items
          ...List.generate(_positions.length, (index) => _buildDraggablePhoto(index)),
          
          // Editorial Text Element
          Positioned(
            bottom: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('zine.symphony'), style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12, letterSpacing: 4)),
                Text(context.tr('zine.soul'), style: const TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.background, fontSize: 48, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildToolbar(),
    );
  }

  Widget _buildDraggablePhoto(int index) {
    return Positioned(
      left: _positions[index].dx,
      top: _positions[index].dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _positions[index] += details.delta;
            _selectedIndex = index;
          });
          HapticsUtility.dialClick();
        },
        onScaleUpdate: (details) {
           _updateRotation(details.rotation);
        },
        child: Transform.rotate(
          angle: _rotations[index],
          child: Container(
            width: 160,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              boxShadow: [
                BoxShadow(color: AppColors.background.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
              ],
              border: Border.all(color: AppColors.textPrimary, width: 8),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Center(child: Icon(AppIcons.addPhoto, color: AppColors.background, size: 40)),
                if (_isLive[index])
                  Container(
                    color: AppColors.background.withOpacity(0.05),
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(AppIcons.live, color: AppColors.background, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        border: Border(top: BorderSide(color: AppColors.background.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolbarIcon(icon: AppIcons.add, label: context.tr('zine.toolbar.add_media'), onTap: _addPhoto),
          _ToolbarIcon(icon: AppIcons.textFields, label: context.tr('zine.toolbar.add_text')),
          _ToolbarIcon(icon: AppIcons.layout, label: context.tr('zine.toolbar.auto_layout'), onTap: _generateAutoLayout),
          _ToolbarIcon(icon: AppIcons.themes, label: context.tr('zine.toolbar.themes')),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ToolbarIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }
}

/// Sovereign offline paper grain painter â€” zero network calls.
class _PaperGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const grainSize = 2.0;
    for (double y = 0; y < size.height; y += grainSize * 2) {
      for (double x = 0; x < size.width; x += grainSize * 2) {
        // Deterministic pseudo-random grain based on position
        final noise = ((x * 31 + y * 17) % 255) / 255.0;
        if (noise > 0.55) {
          paint.color = Color.fromRGBO(80, 60, 40, noise * 0.6);
          canvas.drawRect(Rect.fromLTWH(x, y, grainSize, grainSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


