import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CustomPickImage extends StatefulWidget {
  final Function(File?)? onImageSelected;
  final File? selectedImage;
  const CustomPickImage({super.key, this.onImageSelected, this.selectedImage});

  @override
  State<CustomPickImage> createState() => _CustomPickImageState();
}

class _CustomPickImageState extends State<CustomPickImage> {
  File? _localSelectedImage;

  File? get selectedImage => widget.selectedImage ?? _localSelectedImage;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _localSelectedImage = imageFile;
      });

      // Notifier le parent
      widget.onImageSelected?.call(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Theme.of(context)
              .textTheme
              .titleMedium
              ?.color
              ?.withValues(alpha: 0.2),
          onTap: pickImage,
          child: Center(
            child: selectedImage == null
                ? Icon(
              Icons.image,
              size: 25,
              color: Theme.of(context).textTheme.titleMedium?.color,
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                selectedImage!,
                height: 55,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
