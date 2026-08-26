import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  // ============================================================
  // Cloudinary Settings
  // ============================================================

  static const String _cloudName = 'ownsdmuj';

  static const String _uploadPreset = 'bloom_profiles';

  // ============================================================
  // Upload Image
  // ============================================================

  Future<String> uploadImage({
    required File imageFile,
    required String folder,
    required String publicId,
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
          '$_cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    // ----------------------------------------------------------
    // Upload Preset
    // ----------------------------------------------------------

    request.fields['upload_preset'] = _uploadPreset;

    // ----------------------------------------------------------
    // Folder
    // ----------------------------------------------------------

    request.fields['folder'] = folder;

    // ----------------------------------------------------------
    // Public ID
    // ----------------------------------------------------------

    request.fields['public_id'] = publicId;

    // ----------------------------------------------------------
    // Image File
    // ----------------------------------------------------------

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    // ----------------------------------------------------------
    // Send Request
    // ----------------------------------------------------------

    final response = await request.send();

    final responseBody =
    await response.stream.bytesToString();

    // ----------------------------------------------------------
    // Check Response
    // ----------------------------------------------------------

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed: '
            '${response.statusCode} '
            '$responseBody',
      );
    }

    // ----------------------------------------------------------
    // Convert Response to JSON
    // ----------------------------------------------------------

    final data =
    jsonDecode(responseBody)
    as Map<String, dynamic>;

    final secureUrl =
    data['secure_url']?.toString();

    if (secureUrl == null ||
        secureUrl.isEmpty) {
      throw Exception(
        'Cloudinary did not return an image URL.',
      );
    }

    return secureUrl;
  }
}