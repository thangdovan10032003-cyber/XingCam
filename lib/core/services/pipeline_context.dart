import 'package:flutter/foundation.dart';
import 'package:xingcam/core/models/edit_command.dart';

/// PipelineContext: State manager for the Next-Gen NDE Editing Pipeline.
/// 
/// It tracks a single 'Master Image' and a stack of 'EditCommands',
/// allowing for non-destructive, metadata-driven photography adjustments.
class PipelineContext extends ChangeNotifier {
  static final PipelineContext _instance = PipelineContext._internal();
  factory PipelineContext() => _instance;
  PipelineContext._internal();

  String? _masterImagePath;
  String? _proxyImagePath;
  final List<EditCommand> _commandStack = [];
  final List<List<EditCommand>> _checkpointStack = [];
  String? _peekCommandId;

  String? get currentImagePath => _proxyImagePath ?? _masterImagePath;
  String? get originalImagePath => _masterImagePath;
  String? get masterImagePath => _masterImagePath;
  
  List<EditCommand> get editCommands {
    if (_peekCommandId == null) return List.unmodifiable(_commandStack);
    // Return commands up to and including the peeked ID
    final index = _commandStack.indexWhere((c) => c.id == _peekCommandId);
    if (index == -1) return List.unmodifiable(_commandStack);
    return List.unmodifiable(_commandStack.sublist(0, index + 1));
  }
  
  bool get isPeeking => _peekCommandId != null;

  /// Creates a point-in-time recovery checkpoint for the current NDE state.
  void createCheckpoint() {
    _checkpointStack.add(List.from(_commandStack));
    if (_checkpointStack.length > 5) _checkpointStack.removeAt(0); // Keep last 5
  }

  /// Reverts the NDE state to the most recent stable checkpoint.
  void rollback() {
    if (_checkpointStack.isNotEmpty) {
      _commandStack.clear();
      _commandStack.addAll(_checkpointStack.removeLast());
      notifyListeners();
    }
  }

  void setMasterImage(String masterPath, {String? proxyPath}) {
    _masterImagePath = masterPath;
    _proxyImagePath = proxyPath;
    _commandStack.clear();
    notifyListeners();
  }

  void addCommand(EditCommand command) {
    _commandStack.add(command);
    notifyListeners();
  }

  /// Removes a specific command from the stack by its ID.
  /// Allows for non-linear surgical undo/deletion.
  void removeCommand(String id) {
    _commandStack.removeWhere((cmd) => cmd.id == id);
    notifyListeners();
  }

  void undo() {
    if (_commandStack.isNotEmpty) {
      _commandStack.removeLast();
      notifyListeners();
    }
  }

  /// Temporarily isolates the pipeline to a specific point in history.
  void peekState(String id) {
    _peekCommandId = id;
    notifyListeners();
  }

  /// Restores the pipeline to its full real-time stack.
  void resetPeek() {
    _peekCommandId = null;
    notifyListeners();
  }

  void clear() {
    _masterImagePath = null;
    _commandStack.clear();
    notifyListeners();
  }

  /// Terminates the current editing workflow and flushes the pipeline cache.
  void endSession() {
    clear();
  }

  /// Resets the singleton to a clean state. Use only in tests.
  @visibleForTesting
  void reset() {
    _masterImagePath = null;
    _commandStack.clear();
    _checkpointStack.clear();
  }

  /// Returns suggestions for the "Next Edit" based on the current context.
  List<PipelineSuggestion> getNextSteps() {
    return [
      PipelineSuggestion(
        id: 'beautify',
        label: 'Smooth Skin',
        icon: 'face_retouching_natural_rounded',
      ),
      PipelineSuggestion(
        id: 'spot',
        label: 'Remove Blemishes',
        icon: 'healing_rounded',
      ),
      PipelineSuggestion(
        id: 'eraser',
        label: 'Magic Eraser',
        icon: 'auto_fix_high_rounded',
      ),
      PipelineSuggestion(
        id: 'borders',
        label: 'Add Frame',
        icon: 'settings_overscan_rounded',
      ),
    ];
  }
}

class PipelineSuggestion {
  final String id;
  final String label;
  final String icon;
  PipelineSuggestion({required this.id, required this.label, required this.icon});
}
