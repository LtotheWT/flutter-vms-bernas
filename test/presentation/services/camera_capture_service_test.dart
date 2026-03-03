import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vms_bernas/presentation/services/camera_capture_service.dart';

void main() {
  test('capturePhoto returns file on success', () async {
    final expected = XFile('/tmp/camera.jpg');
    final service = ImagePickerCameraCaptureService(
      pickImage: (source) async {
        expect(source, ImageSource.camera);
        return expected;
      },
    );

    final result = await service.capturePhoto();

    expect(result, expected);
  });

  test('capturePhoto returns null on cancel', () async {
    final service = ImagePickerCameraCaptureService(
      pickImage: (source) async => null,
    );

    final result = await service.capturePhoto();

    expect(result, isNull);
  });

  test('capturePhoto maps platform permission errors', () async {
    final service = ImagePickerCameraCaptureService(
      pickImage: (source) async =>
          throw PlatformException(code: 'camera_access_denied'),
    );

    expect(
      () async => service.capturePhoto(),
      throwsA(
        isA<CameraCaptureException>().having(
          (e) => e.message,
          'message',
          'Camera permission denied. Please enable camera access and try again.',
        ),
      ),
    );
  });
}
