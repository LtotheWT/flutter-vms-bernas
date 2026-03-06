import 'package:equatable/equatable.dart';

class WhitelistGalleryItemEntity extends Equatable {
  const WhitelistGalleryItemEntity({
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
