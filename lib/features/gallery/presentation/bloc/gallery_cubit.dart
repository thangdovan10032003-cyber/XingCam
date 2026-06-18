import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xingcam/features/retro_camera/domain/repositories/retro_camera_repository.dart';
import 'package:xingcam/features/gallery/presentation/bloc/gallery_state.dart';

@injectable
class GalleryCubit extends Cubit<GalleryState> {
  final RetroCameraRepository _repository;
  StreamSubscription? _subscription;

  GalleryCubit(this._repository) : super(GalleryInitial());

  Future<void> loadPhotos() async {
    emit(GalleryLoading());
    final result = await _repository.getCapturedPhotos();
    result.fold(
      (failure) => emit(GalleryError(failure.message)),
      (photos) {
        // Sort by timestamp descending (newest first)
        final sorted = List.of(photos)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        emit(GalleryLoaded(sorted));
      },
    );
  }

  // Auto-refresh when Isar changes (if repository supports it)
  // For now, we manually call loadPhotos when entering the screen
  // or after a new photo is captured.

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

