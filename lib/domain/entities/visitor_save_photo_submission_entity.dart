import 'package:equatable/equatable.dart';

class VisitorSavePhotoSubmissionEntity extends Equatable {
  const VisitorSavePhotoSubmissionEntity({
    required this.imageBase64,
    required this.photoDescription,
    required this.invitationId,
    required this.entity,
    required this.site,
    required this.uploadedBy,
  });

  final String imageBase64;
  final String photoDescription;
  final String invitationId;
  final String entity;
  final String site;
  final String uploadedBy;

  @override
  List<Object?> get props => [
    imageBase64,
    photoDescription,
    invitationId,
    entity,
    site,
    uploadedBy,
  ];
}
