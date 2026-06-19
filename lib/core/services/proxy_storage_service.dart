import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

/// ProxyStorageService: Implements the Proxy/LOD (Level of Detail) Pattern.
/// Generates a 2K proxy for real-time lag-free editing of 48MP+ photos.
@lazySingleton
class ProxyStorageService {
  static const int proxyWidth = 2048;

  /// Generates a low-res proxy for a high-res original.
  /// If a proxy already exists on disk, it is returned immediately (cache-hit).
  Future<String> generateProxy(String originalPath) async {
    final originalFile = File(originalPath);
    final directory = await getTemporaryDirectory();
    final proxyPath = '${directory.path}/proxy_${originalFile.uri.pathSegments.last}';

    final proxyFile = File(proxyPath);
    if (await proxyFile.exists()) return proxyPath;

    // Offload heavy resize to a background Isolate to keep UI at 120fps
    final result = await compute(_resizeIsolate, _ResizePayload(
      originalPath: originalPath,
      targetPath: proxyPath,
      width: proxyWidth,
    ));

    return result ?? originalPath; // fallback to original on error
  }

  /// Compiles final export by applying the NDE edit stack to the full-res original.
  /// Runs in a background Isolate to avoid blocking the UI thread.
  Future<File> compileFinalExport(String originalPath, String jsonCommands) async {
    final directory = await getApplicationDocumentsDirectory();
    final outPath = '${directory.path}/export_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Apply edits in background Isolate
    final result = await compute(_applyEditsIsolate, _ExportPayload(
      originalPath: originalPath,
      outputPath: outPath,
      jsonCommands: jsonCommands,
    ));

    return File(result ?? originalPath);
  }
}

// ── Isolate Payloads ──────────────────────────────────────────────────────────

class _ResizePayload {
  final String originalPath;
  final String targetPath;
  final int width;
  const _ResizePayload({required this.originalPath, required this.targetPath, required this.width});
}

class _ExportPayload {
  final String originalPath;
  final String outputPath;
  final String jsonCommands;
  const _ExportPayload({required this.originalPath, required this.outputPath, required this.jsonCommands});
}

// ── Top-level Isolate functions ───────────────────────────────────────────────

Future<String?> _resizeIsolate(_ResizePayload payload) async {
  try {
    final bytes = await File(payload.originalPath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final resized = img.copyResize(image, width: payload.width);
    await File(payload.targetPath).writeAsBytes(img.encodeJpg(resized, quality: 85));
    return payload.targetPath;
  } catch (e) {
    return null;
  }
}

Future<String?> _applyEditsIsolate(_ExportPayload payload) async {
  try {
    final bytes = await File(payload.originalPath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // ── NDE Command Pipe ───────────────────────────────────────────────────
    final List<dynamic> commands = jsonDecode(payload.jsonCommands);
    
    for (final cmd in commands) {
      final type = cmd['type'];
      final params = cmd['params'] as Map<String, dynamic>;

      if (type == 'beauty') {
        final smooth = params['smooth'] ?? 0.5;
        // High-end Gaussian Selective Blur Simulation
        img.gaussianBlur(image, radius: (smooth * 10).toInt());
      } else if (type == 'grain') {
        final amount = params['amount'] ?? 0.2;
        final seed = params['seed'] ?? DateTime.now().millisecondsSinceEpoch;
        final rand = math.Random(seed);
        
        // Procedural Temporal Grain injection (Non-linear density)
        for (var pixel in image) {
          final n = (rand.nextDouble() - 0.5) * 120 * amount;
          // Apply grain with exposure-dependent weighting
          final weight = 1.0 - (pixel.luminance - 0.5).abs() * 2.0;
          final adjustedN = n * weight.clamp(0.2, 1.0);
          
          pixel.r = (pixel.r + adjustedN).clamp(0, 255).toInt();
          pixel.g = (pixel.g + adjustedN).clamp(0, 255).toInt();
          pixel.b = (pixel.b + adjustedN).clamp(0, 255).toInt();
        }
      }
    }

    await File(payload.outputPath).writeAsBytes(img.encodeJpg(image, quality: 98));
    return payload.outputPath;
  } catch (e) {
    return null;
  }
}
