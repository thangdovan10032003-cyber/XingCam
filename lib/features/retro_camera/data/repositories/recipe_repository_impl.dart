import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:xingcam/core/error/failures.dart';
import 'package:xingcam/features/retro_camera/data/models/recipe_isar_model.dart';
import 'package:xingcam/features/retro_camera/domain/entities/film_recipe.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/recipe_repository.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/retro_camera_repository.dart';

@LazySingleton(as: RecipeRepository)
class RecipeRepositoryImpl implements RecipeRepository {
  final Isar _isar;
  final RetroCameraRepository _cameraRepository;

  RecipeRepositoryImpl(this._isar, this._cameraRepository);

  @override
  Future<Either<Failure, List<FilmRecipe>>> getAllRecipes() async {
    try {
      final models = await _isar.recipeIsarModels.where().findAll();
      final presetsRes = await _cameraRepository.getFilterPresets();
      
      return presetsRes.fold(
        (l) => Left(l),
        (presets) {
          final recipes = models.map((m) {
            final filter = presets.firstWhere((p) => p.id == m.filterId);
            return FilmRecipe(
              id: m.id.toString(),
              name: m.name,
              author: m.author,
              filter: filter,
              grainIntensity: m.grainIntensity,
              borderType: m.borderType,
              showDateStamp: m.showDateStamp,
            );
          }).toList();
          return Right(recipes);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveRecipe(FilmRecipe recipe) async {
    try {
      await _isar.writeTxn(() async {
        final model = RecipeIsarModel()
          ..name = recipe.name
          ..author = recipe.author
          ..filterId = recipe.filter.id
          ..grainIntensity = recipe.grainIntensity
          ..borderType = recipe.borderType
          ..showDateStamp = recipe.showDateStamp
          ..createdAt = DateTime.now();
        
        await _isar.recipeIsarModels.put(model);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecipe(String id) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) return Left(DatabaseFailure());
      
      await _isar.writeTxn(() async {
        await _isar.recipeIsarModels.delete(intId);
      });
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
