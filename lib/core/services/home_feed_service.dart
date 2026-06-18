import 'dart:io';
import 'package:flutter/foundation.dart';
import 'recipe_service.dart';
import 'background_task_service.dart';

/// Data model for an item in the Home Feed.
enum HomeFeedItemType { memory, recipe, task, tip }

class HomeFeedItem {
  final String id;
  final HomeFeedItemType type;
  final String title;
  final String? subtitle;
  final String? imagePath;
  final dynamic data; // Original object (EditRecipe, AiTask, etc.)

  const HomeFeedItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imagePath,
    this.data,
  });
}

/// HomeFeedService — Orchestrates dynamic content for the Sovereign Dashboard.
///
/// Gathers:
/// 1. Currently active background tasks.
/// 2. User's saved recipes (Trending/Favorites).
/// 3. Historical photos (Memories).
class HomeFeedService {
  
  /// Gathers all relevant feed items for the current session.
  static Future<List<HomeFeedItem>> getFeedItems() async {
    final List<HomeFeedItem> items = [];

    // 1. Get active tasks (Phase 4 integration)
    final tasks = await BackgroundTaskService.loadQueue();
    final activeTasks = tasks.where((t) => 
      t.status == TaskStatus.running || t.status == TaskStatus.pending).toList();
    
    for (var task in activeTasks) {
      items.add(HomeFeedItem(
        id: task.id,
        type: HomeFeedItemType.task,
        title: 'Đang xử lý ${task.toolId}',
        subtitle: 'Cần thêm một chút thời gian...',
        imagePath: task.inputPath,
        data: task,
      ));
    }

    // 2. Get saved recipes (Phase 3 integration)
    final recipes = await RecipeService.loadAll();
    for (var recipe in recipes.take(3)) { // Show top 3
      items.add(HomeFeedItem(
        id: recipe.id,
        type: HomeFeedItemType.recipe,
        title: recipe.name,
        subtitle: RecipeService.describeRecipe(recipe),
        imagePath: recipe.previewImagePath,
        data: recipe,
      ));
    }

    // 3. Simulated Memories (Future: Scan Isar gallery)
    // items.add(const HomeFeedItem(
    //   id: 'mem_1',
    //   type: HomeFeedItemType.memory,
    //   title: 'Kỷ niệm từ 1 năm trước',
    //   subtitle: 'Bạn có muốn làm nét lại bức ảnh này?',
    // ));

    return items;
  }
}
