abstract interface class GallerySaveService {
  Future<String> saveImage({
    required String filePath,
    required String fileName,
  });
}
