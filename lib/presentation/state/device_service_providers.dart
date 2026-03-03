import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/camera_capture_service.dart';

final cameraCaptureServiceProvider = Provider<CameraCaptureService>((ref) {
  return ImagePickerCameraCaptureService();
});
