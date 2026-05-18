import 'package:flutter/material.dart';

typedef SharedAnswerOptionBuilder =
    Widget Function(BuildContext context, SharedAnswerOption option);

class SharedAnswerSelection extends StatefulWidget {
  const SharedAnswerSelection({
    super.key,
    required this.questionKey,
    required this.options,
    required this.confirmLabel,
    required this.onConfirm,
    required this.optionBuilder,
    this.selectedIndex,
    this.correctIndex,
    this.revealResult = false,
    this.enabled = true,
    this.forceCompact = false,
    this.fillAvailable = false,
    this.keyPrefix = 'shared_answer',
    this.gridBreakpoint = 720,
    this.spacing = 8,
    this.confirmMinHeight = 48,
  });

  final Object questionKey;
  final List<String> options;
  final int? selectedIndex;
  final int? correctIndex;
  final bool revealResult;
  final bool enabled;
  final bool forceCompact;
  final bool fillAvailable;
  final String keyPrefix;
  final String confirmLabel;
  final double gridBreakpoint;
  final double spacing;
  final double confirmMinHeight;
  final ValueChanged<int> onConfirm;
  final SharedAnswerOptionBuilder optionBuilder;

  @override
  State<SharedAnswerSelection> createState() => _SharedAnswerSelectionState();
}

class _SharedAnswerSelectionState extends State<SharedAnswerSelection> {
  int? _pendingIndex;

  @override
  void initState() {
    super.initState();
    _pendingIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant SharedAnswerSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionKey != widget.questionKey ||
        oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.revealResult != widget.revealResult ||
        oldWidget.options.length != widget.options.length) {
      _pendingIndex = widget.selectedIndex;
    }
  }

  void _select(int index) {
    if (!widget.enabled || widget.revealResult) return;
    setState(() {
      _pendingIndex = index;
    });
  }

  void _confirm() {
    final index = _pendingIndex;
    if (!widget.enabled ||
        widget.revealResult ||
        index == null ||
        index == widget.selectedIndex) {
      return;
    }
    widget.onConfirm(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            widget.forceCompact ||
            constraints.maxWidth < 520 ||
            (!widget.fillAvailable &&
                constraints.hasBoundedHeight &&
                constraints.maxHeight < 360);
        final useGrid =
            !compact &&
            widget.options.length == 4 &&
            constraints.maxWidth >= widget.gridBreakpoint;
        final boundedHeight =
            widget.fillAvailable &&
            constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite;
        final optionTiles = [
          for (var index = 0; index < widget.options.length; index++)
            widget.optionBuilder(
              context,
              SharedAnswerOption(
                index: index,
                key: ValueKey('${widget.keyPrefix}_option_$index'),
                label: widget.options[index],
                marker: String.fromCharCode(65 + (index % 26)),
                isSelected: _pendingIndex == index,
                isCorrect: widget.revealResult && widget.correctIndex == index,
                isWrong:
                    widget.revealResult &&
                    widget.selectedIndex == index &&
                    widget.correctIndex != null &&
                    widget.correctIndex != index,
                isRevealed: widget.revealResult,
                compact: compact,
                onTap: () => _select(index),
              ),
            ),
        ];
        final canConfirm =
            widget.enabled &&
            !widget.revealResult &&
            _pendingIndex != null &&
            _pendingIndex != widget.selectedIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (boundedHeight)
              Expanded(child: _buildBoundedOptions(optionTiles, useGrid))
            else
              _buildShrinkWrapOptions(optionTiles, useGrid),
            SizedBox(height: widget.spacing),
            FilledButton(
              key: ValueKey('${widget.keyPrefix}_confirm'),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(widget.confirmMinHeight),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: canConfirm ? _confirm : null,
              child: Text(widget.confirmLabel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoundedOptions(List<Widget> tiles, bool useGrid) {
    if (useGrid && tiles.length == 4) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: tiles[0]),
                SizedBox(width: widget.spacing),
                Expanded(child: tiles[1]),
              ],
            ),
          ),
          SizedBox(height: widget.spacing),
          Expanded(
            child: Row(
              children: [
                Expanded(child: tiles[2]),
                SizedBox(width: widget.spacing),
                Expanded(child: tiles[3]),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        for (var index = 0; index < tiles.length; index++) ...[
          Expanded(child: tiles[index]),
          if (index < tiles.length - 1) SizedBox(height: widget.spacing),
        ],
      ],
    );
  }

  Widget _buildShrinkWrapOptions(List<Widget> tiles, bool useGrid) {
    if (useGrid && tiles.length == 4) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: widget.spacing,
        mainAxisSpacing: widget.spacing,
        childAspectRatio: 4.8,
        children: tiles,
      );
    }
    return Column(
      children: [
        for (var index = 0; index < tiles.length; index++) ...[
          tiles[index],
          if (index < tiles.length - 1) SizedBox(height: widget.spacing),
        ],
      ],
    );
  }
}

class SharedAnswerOption {
  const SharedAnswerOption({
    required this.index,
    required this.key,
    required this.label,
    required this.marker,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isRevealed,
    required this.compact,
    required this.onTap,
  });

  final int index;
  final Key key;
  final String label;
  final String marker;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isRevealed;
  final bool compact;
  final VoidCallback onTap;
}
