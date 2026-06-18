import 'package:flutter/material.dart';
import 'package:xingcam/core/services/editor_compiler_service.dart';
import 'package:xingcam/core/services/pipeline_context.dart';
import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:easy_localization/easy_localization.dart';

/// AiEditInput: A multi-modal intent-driven editing interface.
/// Features a glowing mic button for voice commands and a text input
/// that feeds into the EditorCompilerService.
class AiEditInput extends StatefulWidget {
  final PipelineContext context;

  const AiEditInput({super.key, required this.context});

  @override
  State<AiEditInput> createState() => _AiEditInputState();
}

class _AiEditInputState extends State<AiEditInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;
  bool _isProcessing = false;

  Future<void> _handleIntent(String prompt) async {
    if (prompt.isEmpty) return;

    setState(() => _isProcessing = true);
    HapticsUtility.dialClick();

    try {
      final commands = await EditorCompilerService.compileIntent(prompt);
      for (final cmd in commands) {
        widget.context.addCommand(cmd);
      }
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(AppIcons.check, color: AppColors.mint, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Applied ${commands.length} sovereign edits: ${commands.map((c) => c?.type.name.toUpperCase()).join(", ")}',
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surface.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Error: Could not understand intent.')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    HapticsUtility.dialClick();
    
    if (_isListening) {
      // Logic for STT (reusing KineticCaptionService principles)
      Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
            _handleIntent('LÃ m má»‹n da vÃ  Ã¡p mÃ u phim'); // Simulated voice result
          }
      });
    }
  }

  final List<String> _inspirationTags = [
    'Retro Glow', 'Golden Hour', 'Noir Cinema', 'Dreamy Pastel', 'Skin Smooth', 'Teeth White'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInspirationTags(),
        const SizedBox(height: 12),
        _buildInputContainer(),
      ],
    );
  }

  Widget _buildInspirationTags() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _inspirationTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _inspirationTags[index];
          return GestureDetector(
            onTap: () => _handleIntent(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(tag, 
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        boxShadow: [
          if (_isListening || _isProcessing)
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? AppColors.secondary : AppColors.accent.withOpacity(0.1),
              ),
              child: Icon(
                _isListening ? AppIcons.micOff : AppIcons.mic,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Tell AI how to edit...',
                hintStyle: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
                border: InputBorder.none,
              ),
              onSubmitted: _handleIntent,
            ),
          ),
          if (_isProcessing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            )
          else
            IconButton(
              onPressed: () => _handleIntent(_controller.text),
              icon: const Icon(AppIcons.ai, color: AppColors.accent, size: 20),
            ),
        ],
      ),
    );
  }
}


