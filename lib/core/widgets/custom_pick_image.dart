import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/animations/bicount_pressable.dart';
import 'dart:io';
import 'package:flutter/material.dart';
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

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
    const shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(AppDimens.borderRadiusMedium),
      ),
    );
    return SizedBox(
      height: AppSizes.dp55,
      width: double.infinity,
      child: BicountPressable(
        color: Theme.of(context).cardColor,
        clipBehavior: Clip.antiAlias,
        hoverColor: Theme.of(context).colorScheme.surfaceContainer,
        customBorder: shape,
        onTap: pickImage,
        child: Center(
          child: selectedImage == null
              ? Icon(
                  Icons.image,
                  size: AppSizes.dp25,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                )
              : Ink.image(
                  image: FileImage(selectedImage!),
                  height: AppSizes.dp55,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
