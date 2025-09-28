// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class ImageGenerator{

  Future<File> createImageFile({required bool fromCamera}) async {
    final ImagePicker picker = ImagePicker();
    XFile? imageFile = fromCamera ? await picker.pickImage(
        source: ImageSource.camera)
        :
    await picker.pickImage(source: ImageSource.gallery);
    return compressImage(imageFileToCompress: imageFile!);
  }

  // Commented out cropImage function - using compression instead
  // Future<CroppedFile> cropImage({required XFile imageFileToCrop}) async{
  //   final CroppedFile? croppedFile = await ImageCropper().cropImage(sourcePath: imageFileToCrop.path,
  //       //maxWidth: 1080,
  //       //maxHeight: 120,
  //       aspectRatio: const CropAspectRatio(ratioX: 2.5, ratioY: 2.5));
  //   return croppedFile!;
  // }

  Future<File> compressImage({required XFile imageFileToCompress}) async {
    // Get the file size in bytes
    final file = File(imageFileToCompress.path);
    final fileSize = await file.length();
    
    // If file is already under 2MB, return as is
    if (fileSize <= 2 * 1024 * 1024) {
      return file;
    }

    // Create a temporary directory for compressed image
    final tempDir = Directory.systemTemp;
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Compress the image to under 2MB
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFileToCompress.path, // This is already a String path
      targetPath,
      quality: 85, // Start with 85% quality
      minWidth: 1024, // Minimum width
      minHeight: 1024, // Minimum height
      format: CompressFormat.jpeg,
    );

    if (compressedFile != null) {
      final compressedFileSize = await File(compressedFile.path).length();
      
      // If still over 2MB, reduce quality further
      if (compressedFileSize > 2 * 1024 * 1024) {
        final XFile? furtherCompressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFileToCompress.path, // This is already a String path
          targetPath,
          quality: 70, // Reduce to 70% quality
          minWidth: 800, // Reduce minimum width
          minHeight: 800, // Reduce minimum height
          format: CompressFormat.jpeg,
        );
        
        if (furtherCompressedFile != null) {
          return File(furtherCompressedFile.path);
        }
      }
      
      return File(compressedFile.path);
    }
    
    // If compression fails, return original file
    return file;
  }
}