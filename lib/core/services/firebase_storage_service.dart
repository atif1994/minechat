import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a single image to Firebase Storage
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user for image upload');
        return null;
      }

      // Create a unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final folderPath = folder ?? 'products_images';
      final storagePath = 'users/${user.uid}/$folderPath/$fileName';

      print('📤 Uploading image to: $storagePath');

      // Upload the file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images to Firebase Storage
  Future<List<String>> uploadImages(List<File> imageFiles, {String? folder}) async {
    final List<String> downloadUrls = [];
    
    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder: folder);
      if (url != null) {
        downloadUrls.add(url);
      }
    }
    
    return downloadUrls;
  }

  /// Upload images from local paths
  Future<List<String>> uploadImagesFromPaths(List<String> imagePaths, {String? folder}) async {
    final List<File> imageFiles = imagePaths
        .where((path) => File(path).existsSync())
        .map((path) => File(path))
        .toList();
    
    return await uploadImages(imageFiles, folder: folder);
  }

  /// Delete an image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Check if a URL is a Firebase Storage URL
  bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  /// Get a reference to Firebase Storage
  Reference get storageRef => _storage.ref();
}
