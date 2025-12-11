import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CustomSearchField({super.key, required this.controller, this.onChanged});

  @override
  _CustomSearchFieldState createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  void _clearText() {
    widget.controller?.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(widget.controller!.text);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: widget.controller,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.inactiveColorDark,
              ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
          suffixIcon: widget.controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearText,
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }
}