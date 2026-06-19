import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xingcam/core/services/pipeline_context.dart';
import 'package:xingcam/core/models/edit_command.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PipelineContext — Core NDE Operations', () {
    late PipelineContext ctx;

    setUp(() {
      ctx = PipelineContext();
      ctx.reset();
      ctx.setMasterImage('/test/image.jpg');
    });

    test('setMasterImage clears previous command stack', () {
      ctx.addCommand(EditCommand(type: EditType.lut, params: {'id': 'fuji'}));
      ctx.setMasterImage('/test/new_image.jpg');
      expect(ctx.editCommands, isEmpty);
    });

    test('addCommand increments stack correctly', () {
      ctx.addCommand(EditCommand(type: EditType.grain, params: {'amount': 0.5}));
      ctx.addCommand(EditCommand(type: EditType.beauty, params: {'smooth': 0.7}));
      expect(ctx.editCommands.length, 2);
    });

    test('undo removes the last command', () {
      ctx.addCommand(EditCommand(type: EditType.lut, params: {}));
      ctx.addCommand(EditCommand(type: EditType.grain, params: {}));
      ctx.undo();
      expect(ctx.editCommands.length, 1);
      expect(ctx.editCommands.first.type, EditType.lut);
    });

    test('undo on empty stack does not throw', () {
      expect(() => ctx.undo(), returnsNormally);
    });
  });

  group('PipelineContext — Transactional Rollback (Phase 111)', () {
    late PipelineContext ctx;

    setUp(() {
      ctx = PipelineContext();
      ctx.reset();
      ctx.setMasterImage('/test/image.jpg');
    });

    test('createCheckpoint saves current state', () {
      ctx.addCommand(EditCommand(type: EditType.lut, params: {}));
      ctx.createCheckpoint();
      ctx.addCommand(EditCommand(type: EditType.grain, params: {}));
      expect(ctx.editCommands.length, 2);
    });

    test('rollback restores the previous checkpoint state', () {
      ctx.addCommand(EditCommand(type: EditType.lut, params: {}));
      ctx.createCheckpoint();          // Save: [lut]
      ctx.addCommand(EditCommand(type: EditType.grain, params: {})); // Stack: [lut, grain]

      ctx.rollback();                   // Restore to [lut]
      expect(ctx.editCommands.length, 1);
      expect(ctx.editCommands.first.type, EditType.lut);
    });

    test('rollback on empty checkpoint stack does not throw', () {
      expect(() => ctx.rollback(), returnsNormally);
    });

    test('checkpoint stack is capped at 5 entries', () {
      for (int i = 0; i < 8; i++) {
        ctx.addCommand(EditCommand(type: EditType.values[i % EditType.values.length], params: {}));
        ctx.createCheckpoint();
      }
      
      // Add one final command so that the first rollback actually changes something
      ctx.addCommand(EditCommand(type: EditType.border, params: {}));
      
      // Rollback only succeeds 5 times before stack empties
      int rollbackCount = 0;
      while (true) {
        final before = ctx.editCommands.length;
        ctx.rollback();
        if (ctx.editCommands.length == before) break;
        rollbackCount++;
        if (rollbackCount > 10) fail('Rollback loop exceeded maximum iterations');
      }
      expect(rollbackCount, 5); // Should exactly be 5 (the limit)
    });
  });

  group('EditCommand — Serialization', () {
    test('toJson and fromJson are symmetric', () {
      final cmd = EditCommand(
        type: EditType.lut,
        params: {'id': 'kodak_xt3', 'intensity': 0.85},
      );
      final json = cmd.toJson();
      final restored = EditCommand.fromJson(json);
      expect(restored.type, cmd.type);
      expect(restored.params['id'], 'kodak_xt3');
      expect(restored.params['intensity'], 0.85);
    });
  });

  group('PipelineContext — clear() and Temp Files', () {
    late PipelineContext ctx;

    setUp(() {
      ctx = PipelineContext();
      ctx.reset();
      ctx.setMasterImage('/test/master.jpg');
    });

    test('clear correctly preserves master image and deletes temp files with tieng_temp_ prefix', () {
      final tempDir = Directory.systemTemp;
      final tempFile1 = File('${tempDir.path}/tieng_temp_test1.jpg')..createSync();
      final tempFile2 = File('${tempDir.path}/tieng_temp_test2.jpg')..createSync();
      final keepFile = File('${tempDir.path}/keep_me.jpg')..createSync();
      
      ctx.addCommand(EditCommand(type: EditType.lut, params: {}));
      
      ctx.clear();
      
      expect(ctx.editCommands, isEmpty);
      expect(ctx.masterImagePath, '/test/master.jpg');
      expect(tempFile1.existsSync(), isFalse);
      expect(tempFile2.existsSync(), isFalse);
      expect(keepFile.existsSync(), isTrue);
      
      // Cleanup
      if (keepFile.existsSync()) keepFile.deleteSync();
    });
  });
}
