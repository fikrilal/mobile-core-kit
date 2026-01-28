import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_core_kit/core/services/media/image_bytes_optimizer.dart';
import 'package:mobile_core_kit/core/services/media/image_picker_service.dart';
import 'package:mobile_core_kit/core/services/media/media_pick_exception.dart';
import 'package:mobile_core_kit/core/services/media/picked_image.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:path/path.dart' as p;

class ImagePickerServiceImpl implements ImagePickerService {
  ImagePickerServiceImpl({ImagePicker? picker, ImageBytesOptimizer? optimizer})
    : _picker = picker ?? ImagePicker(),
      _optimizer = optimizer ?? const ImageBytesOptimizer();

  final ImagePicker _picker;
  final ImageBytesOptimizer _optimizer;

  @override
  Future<PickedImage?> pickFromGallery() =>
      _pickAndOptimize(source: ImageSource.gallery);

  @override
  Future<PickedImage?> pickFromCamera() =>
      _pickAndOptimize(source: ImageSource.camera);

  Future<PickedImage?> _pickAndOptimize({required ImageSource source}) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return null;

      final originalBytes = await file.readAsBytes();
      final optimizedBytes = _optimizer.optimizeToJpeg(
        Uint8List.fromList(originalBytes),
      );

      final baseName = p.basenameWithoutExtension(file.path).trim();
      final fileName = baseName.isEmpty ? 'profile.jpg' : '$baseName.jpg';

      return PickedImage(
        bytes: optimizedBytes,
        contentType: 'image/jpeg',
        fileName: fileName,
      );
    } on MediaPickException {
      rethrow;
    } on Exception catch (e, st) {
      final mapped = _mapExceptionToMediaPickException(e);
      if (mapped != null) throw mapped;

      Log.error(
        'Unexpected image pick error',
        e,
        st,
        true,
        'ImagePickerService',
      );
      throw MediaPickException(
        MediaPickErrorCode.unexpected,
        message: e.toString(),
        cause: e,
      );
    }
  }

  MediaPickException? _mapExceptionToMediaPickException(Object e) {
    if (e is PlatformException) {
      final code = e.code.toLowerCase();
      if (code.contains('camera_access_denied')) {
        return MediaPickException(
          MediaPickErrorCode.cameraPermissionDenied,
          message: e.message,
          cause: e,
        );
      }
      if (code.contains('photo_access_denied')) {
        return MediaPickException(
          MediaPickErrorCode.photoPermissionDenied,
          message: e.message,
          cause: e,
        );
      }
      if (code.contains('camera_access_restricted') ||
          code.contains('photo_access_restricted')) {
        return MediaPickException(
          MediaPickErrorCode.unavailable,
          message: e.message,
          cause: e,
        );
      }
      return MediaPickException(
        MediaPickErrorCode.unexpected,
        message: e.message,
        cause: e,
      );
    }
    return null;
  }
}
