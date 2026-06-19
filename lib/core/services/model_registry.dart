import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Registry of all on-demand AI models for XingCam.
/// Each model is only downloaded when the user first accesses its feature.
enum AiModel {
  segmentation,
  depthEstimation,
  whisperTiny,
  gaussianSplatting,
  aiUncrop,
}

class AiModelMeta {
  final AiModel id;
  final String url;
  final String fileName;
  final int expectedBytes;     // expected download size
  final String sha256;         // SHA-256 checksum for integrity

  const AiModelMeta({
    required this.id,
    required this.url,
    required this.fileName,
    required this.expectedBytes,
    required this.sha256,
  });

  double get sizeMb => expectedBytes / (1024 * 1024);
}

class ModelRegistry {
  ModelRegistry._();

  static const Map<AiModel, AiModelMeta> catalog = {
    AiModel.segmentation: AiModelMeta(
      id: AiModel.segmentation,
      url: 'https://cdn.xingcam.io/models/v1/mobilesam_v1.tflite',
      fileName: 'mobilesam_v1.tflite',
      expectedBytes: 38500000,
      sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
    AiModel.depthEstimation: AiModelMeta(
      id: AiModel.depthEstimation,
      url: 'https://cdn.xingcam.io/models/v1/depth_v2.tflite',
      fileName: 'depth_v2.tflite',
      expectedBytes: 25000000,
      sha256: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
    ),
    AiModel.whisperTiny: AiModelMeta(
      id: AiModel.whisperTiny,
      url: 'https://cdn.xingcam.io/models/v1/whisper_tiny.tflite',
      fileName: 'whisper_tiny.tflite',
      expectedBytes: 39000000,
      sha256: 'b3a8e0e1f9ab1bfe3a36f231f676f78bb28a3c7e92e07a6e9b9a9e2b1a2c3d4e',
    ),
    AiModel.gaussianSplatting: AiModelMeta(
      id: AiModel.gaussianSplatting,
      url: 'https://cdn.xingcam.io/models/v1/gaussian_splat_v1.ply',
      fileName: 'gaussian_splat_v1.ply',
      expectedBytes: 60000000,
      sha256: 'c4ca4238a0b923820dcc509a6f75849bc81e728d9d4c2f636f067f89cc14862c',
    ),
    AiModel.aiUncrop: AiModelMeta(
      id: AiModel.aiUncrop,
      url: 'https://cdn.xingcam.io/models/v1/outpainting_v1.onnx',
      fileName: 'outpainting_v1.onnx',
      expectedBytes: 47000000,
      sha256: '1679091c5a880faf6fb5e6087eb1b2dc6b5b56b55ab1b5cde1c5b5c5e5f5a5b',
    ),
  };

  /// Returns the local [File] path where a model should be stored.
  static Future<File> localFile(AiModel model) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/xingcam_models');
    if (!modelsDir.existsSync()) modelsDir.createSync(recursive: true);
    return File('${modelsDir.path}/${catalog[model]!.fileName}');
  }

  /// Returns true if the model file already exists on disk.
  static Future<bool> isDownloaded(AiModel model) async {
    final f = await localFile(model);
    return f.existsSync() && f.lengthSync() > 0;
  }

  /// Deletes a locally cached model (e.g. for model update).
  static Future<void> evict(AiModel model) async {
    final f = await localFile(model);
    if (f.existsSync()) await f.delete();
  }

  /// Returns the file-size label for display (e.g. "38.5 MB").
  static String sizeLabel(AiModel model) {
    final mb = catalog[model]!.sizeMb;
    return '${mb.toStringAsFixed(1)} MB';
  }
}
