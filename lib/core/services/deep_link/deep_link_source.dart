abstract class DeepLinkSource {
  Future<Uri?> getInitialUri();

  Stream<Uri> get uriStream;
}

