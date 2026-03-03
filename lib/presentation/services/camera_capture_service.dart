import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

abstract class CameraCaptureService {
  Future<XFile?> capturePhoto();
}

class CameraCaptureException implements Exception {
  const CameraCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImagePickerCameraCaptureService implements CameraCaptureService {
  ImagePickerCameraCaptureService({
    ImagePicker? picker,
    Future<XFile?> Function(ImageSource source)? pickImage,
  }) : _picker = picker ?? ImagePicker(),
       _pickImage = pickImage;

  final ImagePicker _picker;
  final Future<XFile?> Function(ImageSource source)? _pickImage;

  @override
  Future<XFile?> capturePhoto() async {
    try {
      if (_pickImage != null) {
        return _pickImage(ImageSource.camera);
      }
      return _picker.pickImage(source: ImageSource.camera);
    } on PlatformException catch (error) {
      throw CameraCaptureException(_messageForPlatformError(error.code));
    } catch (_) {
      throw const CameraCaptureException(
        'Unable to open camera. Please try again.',
      );
    }
  }

  String _messageForPlatformError(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.contains('permission') || normalized.contains('access')) {
      return 'Camera permission denied. Please enable camera access and try again.';
    }
    return 'Unable to open camera. Please try again.';
  }
}
