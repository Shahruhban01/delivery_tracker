import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final String? hint;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _removeOverlay();
          setState(() {
            _isOpen = false;
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        final isSelected = item == widget.value;
                        return GestureDetector(
                          onTap: () {
                            widget.onChanged(item);
                            _removeOverlay();
                            setState(() {
                              _isOpen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFFE3F2FD) 
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected 
                                          ? const Color(0xFF1976D2) 
                                          : const Color(0xFF212121),
                                      fontWeight: isSelected 
                                          ? FontWeight.w600 
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Color(0xFF1976D2),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.value.isEmpty ? (widget.hint ?? 'Select') : widget.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.value.isEmpty 
                        ? const Color(0xFF9E9E9E) 
                        : const Color(0xFF212121),
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: const Color(0xFF757575),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
