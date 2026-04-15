import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:flutter/material.dart';

class SegmentedControlController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}

class SegmentedControlWidget extends StatefulWidget {
  const SegmentedControlWidget({super.key, required this.controller});

  final SegmentedControlController controller;

  @override
  State<SegmentedControlWidget> createState() => _SegmentedControlWidgetState();
}

class _SegmentedControlWidgetState extends State<SegmentedControlWidget> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _segmentKeys = List.generate(3, (_) => GlobalKey());
  final ScrollController _scrollController = ScrollController();

  Rect? _selectedRect;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSelectedRect());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedRect();
      _scrollToSelectedSegment();
    });
  }

  void _updateSelectedRect() {
    if (!mounted) {
      return;
    }

    final stackContext = _stackKey.currentContext;
    final segmentContext =
        _segmentKeys[widget.controller.selectedIndex].currentContext;
    if (stackContext == null || segmentContext == null) {
      return;
    }

    final stackBox = stackContext.findRenderObject() as RenderBox?;
    final segmentBox = segmentContext.findRenderObject() as RenderBox?;
    if (stackBox == null || segmentBox == null) {
      return;
    }

    final offset = segmentBox.localToGlobal(Offset.zero, ancestor: stackBox);
    final nextRect = offset & segmentBox.size;

    if (_selectedRect == nextRect) {
      return;
    }

    setState(() {
      _selectedRect = nextRect;
    });
  }

  void _scrollToSelectedSegment() {
    final segmentContext =
        _segmentKeys[widget.controller.selectedIndex].currentContext;
    if (segmentContext == null || !_scrollController.hasClients) {
      return;
    }

    Scrollable.ensureVisible(
      segmentContext,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : 0.0;

                return ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minWidth),
                  child: Stack(
                    key: _stackKey,
                    children: [
                      if (_selectedRect != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: _selectedRect!.left,
                          top: _selectedRect!.top,
                          width: _selectedRect!.width,
                          height: _selectedRect!.height,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C6C6C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: _buildSegment(
                              context.l10n.transactionTypeExpense,
                              0,
                            ),
                          ),
                          Expanded(
                            child: _buildSegment(
                              context.l10n.transactionTypeIncome,
                              1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(String text, int index) {
    final isSelected = widget.controller.selectedIndex == index;

    return GestureDetector(
      key: _segmentKeys[index],
      onTap: () => widget.controller.setSelectedIndex(index),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          text,
          style: isSelected
              ? TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                )
              : Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
