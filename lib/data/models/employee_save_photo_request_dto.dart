import '../../domain/entities/employee_save_photo_submission_entity.dart';

class EmployeeSavePhotoRequestDto {
  const EmployeeSavePhotoRequestDto({
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

  Map<String, dynamic> toJson() {
    return {
      'ImageBase64': imageBase64,
      'PhotoDescription': photoDescription,
      'GUID': guid,
      'Entity': entity,
      'Site': site,
      'UploadedBy': uploadedBy,
    };
  }

  factory EmployeeSavePhotoRequestDto.fromEntity(
    EmployeeSavePhotoSubmissionEntity entity,
  ) {
    return EmployeeSavePhotoRequestDto(
      imageBase64: entity.imageBase64,
      photoDescription: entity.photoDescription,
      guid: entity.guid,
      entity: entity.entity,
      site: entity.site,
      uploadedBy: entity.uploadedBy,
    );
  }
}
