import 'dart:convert';

/// Types of edits supported by the non-destructive pipeline.
enum EditType { lut, grain, beauty, blur, lightLeak, border, crop, transform }

/// EditCommand: A serializable instruction for the NDE pipeline.
class EditCommand {
  final EditType type;
  final Map<String, dynamic> params;
  final String id;
  final String? maskPath; // Optional path to a binary mask file
  final String? maskType; // 'subject', 'sky', 'background', etc.

  EditCommand({
    required this.type,
    required this.params,
    String? id,
    this.maskPath,
    this.maskType,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'params': params,
    'id': id,
    'maskPath': maskPath,
    'maskType': maskType,
  };

  factory EditCommand.fromJson(Map<String, dynamic> json) {
    return EditCommand(
      type: EditType.values.firstWhere((e) => e.name == json['type']),
      params: Map<String, dynamic>.from(json['params']),
      id: json['id'],
      maskPath: json['maskPath'],
      maskType: json['maskType'],
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
