import 'package:flutter/material.dart';

class GifSearchField extends StatefulWidget {
  const GifSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  State<GifSearchField> createState() => _GifSearchFieldState();
}

class _GifSearchFieldState extends State<GifSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'Search GIFs',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: _clear,
                  ),
            filled: true,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
