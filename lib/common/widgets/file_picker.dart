import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';


final ImagePicker _imagePicker = ImagePicker();

  Future<void> _showImagePickerOptions(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding:  EdgeInsets.all(16.0.h),
          margin: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
          color: Colors.white, // Background color for the modal
          borderRadius: BorderRadius.circular(20.h),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async  {
                  // Navigator.pop(context);
                 final result  = await  _pickImageFromCamera(context);
                 Navigator.pop(context,result);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  // Navigator.pop(context);
                  final result = await _pickImageFromGallery(context);
                  Navigator.pop(context,result);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String,dynamic>> _pickPdfFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      final file = result.files.first;
      return {"fileObj":file};
    } else {
     return {};
    }
  }


Future<void> showFilePickerOptions(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (
      BuildContext context) {
      return Container(
        padding:  EdgeInsets.all(16.0.h),
        margin: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
        color: Colors.white, // Background color for the modal
        borderRadius: BorderRadius.circular(20.h),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                _showImagePickerOptions(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                _pickPdfFile(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

  Future<Map<String,dynamic>> _pickImageFromCamera(BuildContext context) async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
        return {"fileObject":photo};
    } else {
        return {"fileObject":photo};
    }
  }

  Future<Map<String,dynamic>> _pickImageFromGallery(BuildContext context) async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
       return {"fileObject":image};
    } else {
       return {};
    }
  }
