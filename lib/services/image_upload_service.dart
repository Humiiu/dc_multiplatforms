import 'dart:io' show File;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> pickAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return null;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final ref = _storage.ref().child('profile_photos/$uid.jpg');
      
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // Pada mobile, gunakan putFile untuk efisiensi
        await ref.putFile(File(picked.path), SettableMetadata(contentType: 'image/jpeg'));
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('[ImageUploadService] error: $e');
      return null;
    }
  }
}
