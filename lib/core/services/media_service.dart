import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class MediaService extends GetxController {
  static MediaService get instance => Get.find<MediaService>();
  
  final _audioRecorder = FlutterSoundRecorder();
  final _imagePicker = ImagePicker();
  
  var isRecording = false.obs;
  var recordingDuration = 0.obs;
  var recordingPath = ''.obs;
  var recordingTimer = Rx<Timer?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Don't call Get.put here as it creates infinite loop
    // The service should be initialized in main.dart
  }
  
  @override
  void onClose() {
    stopRecording();
    _audioRecorder.closeRecorder();
    super.onClose();
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    // Request microphone permission
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      Get.snackbar(
        'Permission Required',
        'Microphone permission is needed for voice recording',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Request storage permission for images
    final storagePermission = await Permission.storage.request();
    if (!storagePermission.isGranted) {
      Get.snackbar(
        'Permission Required',
        'Storage permission is needed for image selection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Show image picker options
  Future<String?> pickImage(BuildContext context) async {
    if (!await requestPermissions()) return null;

    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () async {
                final image = await _pickImageFromCamera();
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final image = await _pickImageFromGallery();
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera
  Future<String?> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );
      
      if (image != null) {
        // Copy to permanent directory
        return await _copyImageToPermanentDirectory(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<String?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 75,
      );
      
      if (image != null) {
        // Copy to permanent directory
        return await _copyImageToPermanentDirectory(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to select image: $e');
      return null;
    }
  }

  /// Copy image to permanent directory to prevent deletion
  Future<String> _copyImageToPermanentDirectory(String sourcePath) async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final chatImagesDir = Directory('${directory.path}/chat_images');
      
      // Create directory if it doesn't exist
      if (!await chatImagesDir.exists()) {
        await chatImagesDir.create(recursive: true);
      }
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = sourcePath.split('.').last;
      final fileName = 'chat_image_$timestamp.$extension';
      final destinationPath = '${chatImagesDir.path}/$fileName';
      
      // Copy file
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      await sourceFile.copy(destinationPath);
      
      print('📁 Image copied to permanent directory: $destinationPath');
      return destinationPath;
    } catch (e) {
      print('❌ Error copying image to permanent directory: $e');
      // Fallback to original path if copy fails
      return sourcePath;
    }
  }

  /// Start voice recording
  Future<bool> startRecording() async {
    if (!await requestPermissions()) return false;

    try {
      await _audioRecorder.openRecorder();
      
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );
      
      isRecording.value = true;
      recordingPath.value = path;
      recordingDuration.value = 0;
      
      // Start timer
      recordingTimer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration.value++;
      });
      
      Get.snackbar(
        'Recording Started',
        'Voice recording in progress...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
    return false;
  }

  /// Stop voice recording
  Future<String?> stopRecording() async {
    try {
      if (isRecording.value) {
        final path = await _audioRecorder.stopRecorder();
        recordingTimer.value?.cancel();
        isRecording.value = false;
        
        if (path != null && recordingDuration.value > 0) {
          Get.snackbar(
            'Recording Stopped',
            'Voice message recorded (${recordingDuration.value}s)',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return path;
        } else {
          Get.snackbar('Error', 'Recording too short or failed');
          return null;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording: $e');
    }
    return null;
  }

  /// Cancel voice recording
  Future<void> cancelRecording() async {
    try {
      if (isRecording.value) {
        await _audioRecorder.stopRecorder();
        recordingTimer.value?.cancel();
        isRecording.value = false;
        recordingDuration.value = 0;
        
        // Delete the file if it exists
        if (recordingPath.value.isNotEmpty) {
          final file = File(recordingPath.value);
          if (await file.exists()) {
            await file.delete();
          }
        }
        recordingPath.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel recording: $e');
    }
  }

  /// Get formatted recording duration
  String getFormattedDuration() {
    final minutes = recordingDuration.value ~/ 60;
    final seconds = recordingDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Show emoji picker
  void showEmojiPicker(BuildContext context, Function(Emoji emoji) onEmojiSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPicker(
        onEmojiSelected: (category, emoji) {
          onEmojiSelected(emoji);
          Navigator.pop(context);
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: const EmojiViewConfig(
            emojiSizeMax: 28,
            backgroundColor: Color(0xFFF2F2F2),
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            loadingIndicator: SizedBox.shrink(),
          ),
          swapCategoryAndBottomBar: false,
          skinToneConfig: const SkinToneConfig(
            enabled: true,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            backgroundColor: Color(0xFFF2F2F2),
            buttonColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  /// Upload image to Firebase Storage (if needed)
  Future<String?> uploadImageToStorage(String imagePath) async {
    try {
      // For now, we'll return the local path
      // In a real implementation, you'd upload to Firebase Storage
      // and return the download URL
      return imagePath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    }
  }

  /// Upload audio to Firebase Storage (if needed)
  Future<String?> uploadAudioToStorage(String audioPath) async {
    try {
      // For now, we'll return the local path
      // In a real implementation, you'd upload to Firebase Storage
      // and return the download URL
      return audioPath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload audio: $e');
      return null;
    }
  }
}
