import 'package:equatable/equatable.dart';
import 'package:xingcam/features/retro_camera/domain/entities/captured_photo.dart';

sealed class GalleryState extends Equatable {
  const GalleryState();
  @override
  List<Object?> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<CapturedPhoto> photos;
  const GalleryLoaded(this.photos);

  @override
  List<Object?> get props => [photos];
}

class GalleryError extends GalleryState {
  final String message;
  const GalleryError(this.message);

  @override
  List<Object?> get props => [message];
}
