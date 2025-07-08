import 'package:bicount/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController controller;

  const CustomSearchField({super.key, required this.controller});

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        CustomTextField(
          title: '', // tu peux masquer le titre si tu veux
          label: 'Search',
          textController: widget.controller,
          type: CustomTextFieldType.name,
        ),
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.search, color: Colors.grey),
        ),
      ],
    );
  }
}
