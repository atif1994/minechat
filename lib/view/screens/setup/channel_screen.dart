import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ai_assistant_controller/ai_assistant_controller.dart';


class ChannelsScreen extends StatelessWidget {
  final AIAssistantController controller;

  const ChannelsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Instagram Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // Tab views
          // if (controller.selectedChannelTab.value == 0)
          //   _buildWhatsAppSection()
          // else if (controller.selectedChannelTab.value == 1)
          //   _buildFacebookSection()
          // else
          //   _buildInstagramSection(),
        ],
      ),
    );
  }

  // Widget _buildTab(String title, int index) {
  //   final isSelected = controller.selectedChannelTab.value == index;
  //   return GestureDetector(
  //     onTap: () => controller.selectedChannelTab.value = index,
  //     child: Container(
  //       margin: const EdgeInsets.only(right: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Colors.red[400] : Colors.transparent,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: isSelected ? Colors.red[400]! : Colors.grey[300]!,
  //         ),
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : Colors.grey[600],
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWhatsAppSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WhatsApp Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Here you can configure WhatsApp API, webhook, etc.'),
      ],
    );
  }

  Widget _buildFacebookSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Facebook Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Here you can connect Facebook pages or Messenger bot.'),
      ],
    );
  }

  Widget _buildInstagramSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instagram Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Here you can link your Instagram business account.'),
      ],
    );
  }
}
