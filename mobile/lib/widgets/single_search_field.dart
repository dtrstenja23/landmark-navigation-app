import 'package:flutter/material.dart';

class SingleSearchField extends StatelessWidget {
  const SingleSearchField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.onTap,
    required this.onChanged,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onTap: onTap,
      decoration: const InputDecoration(
        hintText: 'Traži lokaciju...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey),
      ),
      onChanged: onChanged,
    );
  }
}
