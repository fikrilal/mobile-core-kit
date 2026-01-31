import 'package:mobile_core_kit/core/platform/media/picked_image.dart';

abstract interface class ImagePickerService {
  /// Returns null when the user cancels.
  Future<PickedImage?> pickFromGallery();

  /// Returns null when the user cancels.
  Future<PickedImage?> pickFromCamera();
}
