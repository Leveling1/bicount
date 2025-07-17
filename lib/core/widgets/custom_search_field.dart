import 'package:bicount/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchField({super.key, this.onChanged});

  @override
  _CustomSearchFieldState createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  final TextEditingController _controller = TextEditingController();

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: _controller,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          hintText: "Search",
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: AppColors.inactiveColorDark,
              ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearText,
                )
              : null,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
