import 'package:equatable/equatable.dart';

class WhitelistSavePhotoSubmissionEntity extends Equatable {
  const WhitelistSavePhotoSubmissionEntity({
    required this.imageBase64,
    required this.photoDescription,
    required this.guid,
    required this.entity,
    required this.site,
    required this.uploadedBy,
  });

  final String imageBase64;
  final String photoDescription;
  final String guid;
  final String entity;
  final String site;
  final String uploadedBy;

  @override
  List<Object?> get props => [
    imageBase64,
    photoDescription,
    guid,
    entity,
    site,
    uploadedBy,
  ];
}
