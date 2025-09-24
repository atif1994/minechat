import 'package:flutter/material.dart';

/// AI Enabled indicator widget for chat conversations
class AIEnabledIndicatorWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const AIEnabledIndicatorWidget({
    Key? key,
    this.isEnabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), // Light red background
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.smart_toy,
                  color: Color(0xFFD32F2F), // Dark red
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Enabled',
                  style: TextStyle(
                    color: Color(0xFFD32F2F), // Dark red
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
