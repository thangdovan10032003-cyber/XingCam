import 'package:dartz/dartz.dart';
import 'package:xingcam/core/error/failures.dart';
import '../entities/film_recipe.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<FilmRecipe>>> getAllRecipes();
  Future<Either<Failure, Unit>> saveRecipe(FilmRecipe recipe);
  Future<Either<Failure, Unit>> deleteRecipe(String id);
}
