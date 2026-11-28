import 'package:bicount/core/animations/bicount_pressable.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SettingsOptionSheet<T> extends StatefulWidget {
  const SettingsOptionSheet({
    super.key,
    required this.title,
    required this.description,
    required this.selectedValue,
    required this.options,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String title;
  final String description;
  final T selectedValue;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final Future<void> Function(T value) onSelected;

  @override
  State<SettingsOptionSheet<T>> createState() => _SettingsOptionSheetState<T>();
}

class _SettingsOptionSheetState<T> extends State<SettingsOptionSheet<T>> {
  T? _loadingValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        AppDimens.spacerSmall,
        Text(widget.description, style: Theme.of(context).textTheme.bodySmall),
        AppDimens.spacerMedium,
        ...widget.options.map(
          (option) => BicountPressable(
            onTap: _loadingValue != null
                ? null
                : () async {
                    setState(() {
                      _loadingValue = option;
                    });
                    try {
                      await widget.onSelected(option);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _loadingValue = null;
                        });
                      }
                    }
                  },
            customBorder: Theme.of(context).listTileTheme.shape,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.labelBuilder(option)),
              trailing: _buildTrailing(option),
            ),
          ),
        ),
        AppDimens.spacerMedium,
      ],
    );
  }

  Widget? _buildTrailing(T option) {
    // Si cette option est en cours de chargement
    if (option == _loadingValue) {
      return SizedBox(
        width: AppSizes.dp24,
        height: AppSizes.dp24,
        child: LoadingAnimationWidget.hexagonDots(
          color: Theme.of(context).primaryColor,
          size: AppSizes.dp20,
        ),
      );
    }

    // Si une autre option est en cours de chargement, on cache tous les checks
    if (_loadingValue != null) {
      return null;
    }

    // État initial : on affiche le check uniquement pour la valeur sélectionnée
    if (option == widget.selectedValue) {
      return Icon(Icons.check, color: Theme.of(context).primaryColor);
    }

    return null;
  }
}
