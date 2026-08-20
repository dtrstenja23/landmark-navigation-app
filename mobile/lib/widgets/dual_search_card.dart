import 'package:flutter/material.dart';

class DualSearchCard extends StatelessWidget {
  const DualSearchCard({
    super.key,
    required this.originController,
    required this.destinationController,
    required this.originFocus,
    required this.destinationFocus,
    required this.isCustomOrigin,
    required this.onSearchChanged,
    required this.onTapOrigin,
    required this.onTapDestination,
    required this.onRevertGps,
    required this.onSwap,
  });

  final TextEditingController originController;
  final TextEditingController destinationController;
  final FocusNode originFocus;
  final FocusNode destinationFocus;
  final bool isCustomOrigin;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onTapOrigin;
  final VoidCallback onTapDestination;
  final VoidCallback onRevertGps;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trip_origin,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        focusNode: originFocus,
                        controller: originController,
                        onTap: onTapOrigin,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isCustomOrigin
                                  ? Colors.blue.shade900
                                  : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Unesi polazište...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          suffixIcon:
                              isCustomOrigin
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.my_location,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Vrati na GPS',
                                    onPressed: onRevertGps,
                                  )
                                  : null,
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 12, thickness: 0.8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        focusNode: destinationFocus,
                        controller: destinationController,
                        onTap: onTapDestination,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Unesi odredište...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(
              Icons.swap_vert,
              color: Colors.blue,
              size: 24,
            ),
            tooltip: 'Zamijeni polazište i odredište',
            onPressed: onSwap,
          ),
        ],
      ),
    );
  }
}
