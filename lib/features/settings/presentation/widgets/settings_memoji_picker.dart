import 'package:bicount/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_memoji_catalog_cubit.dart';
import 'package:bicount/features/settings/presentation/bloc/settings_memoji_catalog_state.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_memoji_empty_state.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_memoji_grid.dart';
import 'package:bicount/features/settings/presentation/widgets/settings_memoji_loading_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsMemojiPicker extends StatefulWidget {
  const SettingsMemojiPicker({
    super.key,
    required this.repository,
    required this.selectedImage,
    required this.onSelected,
  });

  final SettingsRepositoryImpl repository;
  final String selectedImage;
  final ValueChanged<String> onSelected;

  @override
  State<SettingsMemojiPicker> createState() => _SettingsMemojiPickerState();
}

class _SettingsMemojiPickerState extends State<SettingsMemojiPicker> {
  late final SettingsMemojiCatalogCubit _cubit;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _cubit = SettingsMemojiCatalogCubit(widget.repository)..hydrate();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsMemojiCatalogCubit, SettingsMemojiCatalogState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.status == SettingsMemojiCatalogStatus.loading &&
            state.items.isEmpty) {
          return const SettingsMemojiLoadingGrid();
        }
        if (state.status == SettingsMemojiCatalogStatus.failure &&
            state.items.isEmpty) {
          return SettingsMemojiEmptyState(onRetry: _cubit.retry);
        }

        return SettingsMemojiGrid(
          controller: _scrollController,
          items: state.items,
          selectedImage: widget.selectedImage,
          isLoadingMore: state.isLoadingMore,
          onSelected: widget.onSelected,
        );
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 240) {
      _cubit.loadMore();
    }
  }
}
