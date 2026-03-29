import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Price range filter slider widget
class PriceSlider extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final String currencySymbol;

  const PriceSlider({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    this.currencySymbol = '₹',
  });

  @override
  State<PriceSlider> createState() => _PriceSliderState();
}

class _PriceSliderState extends State<PriceSlider> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = widget.values;
  }

  @override
  void didUpdateWidget(PriceSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _currentValues = widget.values;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        // Price labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.currencySymbol}${_currentValues.start.round()}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${widget.currencySymbol}${_currentValues.end.round()}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Range slider
        RangeSlider(
          values: _currentValues,
          min: widget.min,
          max: widget.max,
          divisions: ((widget.max - widget.min) / 100).round(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha: 0.2),
          onChanged: (values) {
            setState(() => _currentValues = values);
          },
          onChangeEnd: widget.onChanged,
        ),

        // Min/Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min: ${widget.currencySymbol}${widget.min.round()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Max: ${widget.currencySymbol}${widget.max.round()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple price filter bottom sheet
class PriceFilterBottomSheet extends StatefulWidget {
  final RangeValues initialValues;
  final double min;
  final double max;

  const PriceFilterBottomSheet({
    super.key,
    required this.initialValues,
    required this.min,
    required this.max,
  });

  @override
  State<PriceFilterBottomSheet> createState() => _PriceFilterBottomSheetState();
}

class _PriceFilterBottomSheetState extends State<PriceFilterBottomSheet> {
  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = widget.initialValues;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PriceSlider(
            values: _values,
            min: widget.min,
            max: widget.max,
            onChanged: (values) {
              setState(() => _values = values);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, RangeValues(widget.min, widget.max));
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _values);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
