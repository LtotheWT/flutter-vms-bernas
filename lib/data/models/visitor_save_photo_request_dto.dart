import '../../domain/entities/visitor_save_photo_submission_entity.dart';

class VisitorSavePhotoRequestDto {
  const VisitorSavePhotoRequestDto({
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

  Map<String, dynamic> toJson() {
    return {
      'ImageBase64': imageBase64,
      'PhotoDescription': photoDescription,
      'InvitationId': invitationId,
      'Entity': entity,
      'Site': site,
      'UploadedBy': uploadedBy,
    };
  }

  factory VisitorSavePhotoRequestDto.fromEntity(
    VisitorSavePhotoSubmissionEntity entity,
  ) {
    return VisitorSavePhotoRequestDto(
      imageBase64: entity.imageBase64,
      photoDescription: entity.photoDescription,
      invitationId: entity.invitationId,
      entity: entity.entity,
      site: entity.site,
      uploadedBy: entity.uploadedBy,
    );
  }
}
