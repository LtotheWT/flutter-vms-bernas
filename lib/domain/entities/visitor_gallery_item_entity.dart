import 'package:equatable/equatable.dart';

class VisitorGalleryItemEntity extends Equatable {
  const VisitorGalleryItemEntity({
    required this.photoId,
    required this.photoDesc,
    required this.url,
  });

  final int photoId;
  final String photoDesc;
  final String url;

  @override
  List<Object?> get props => [photoId, photoDesc, url];
}
