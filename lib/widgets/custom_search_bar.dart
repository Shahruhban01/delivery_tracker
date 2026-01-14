import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hint;

  const CustomSearchBar({
    Key? key,
    required this.onSearchChanged,
    this.hint = 'Search...',
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(
            Icons.search,
            color: Color(0xFF757575),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: () {
                _controller.clear();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF757575),
                  size: 18,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
