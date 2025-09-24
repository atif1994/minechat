import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loading_widgets.dart';
import 'custom_card.dart';

/// Generic list widget with loading, empty, and error states
class GenericListWidget<T> extends StatelessWidget {
  final RxList<T> items;
  final RxBool isLoading;
  final RxBool hasError;
  final RxString errorMessage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onRefresh;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  const GenericListWidget({
    Key? key,
    required this.items,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyWidget,
    this.errorWidget,
    this.padding,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return LoadingWidgets.list(message: 'Loading items...');
      }

      if (hasError.value) {
        return errorWidget ?? ErrorStateWidget(
          message: errorMessage.value,
          onRetry: onRefresh,
        );
      }

      if (items.isEmpty) {
        return emptyWidget ?? EmptyStateWidget(
          icon: Icons.list_alt,
          title: 'No items found',
          subtitle: 'Pull down to refresh or add a new item',
          action: onRefresh != null ? ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Refresh'),
          ) : null,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) onRefresh!();
        },
        child: ListView.builder(
          controller: scrollController,
          padding: padding ?? const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index], index);
          },
        ),
      );
    });
  }
}

/// Chat list item widget
class ChatListItem extends StatelessWidget {
  final String contactName;
  final String lastMessage;
  final String timestamp;
  final String? profileImageUrl;
  final int unreadCount;
  final String platform;
  final VoidCallback? onTap;

  const ChatListItem({
    Key? key,
    required this.contactName,
    required this.lastMessage,
    required this.timestamp,
    this.profileImageUrl,
    this.unreadCount = 0,
    this.platform = 'Unknown',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? NetworkImage(profileImageUrl!)
            : null,
        child: profileImageUrl == null || profileImageUrl!.isEmpty
            ? Text(
                contactName.isNotEmpty ? contactName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      title: Text(
        contactName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lastMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            timestamp,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}

/// Lead list item widget
class LeadListItem extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final String source;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LeadListItem({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.source,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            phone,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildStatusChip(status),
              const SizedBox(width: 8),
              Text(
                source,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              if (onEdit != null) onEdit!();
              break;
            case 'delete':
              if (onDelete != null) onDelete!();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'hot':
        color = Colors.red;
        break;
      case 'warm':
        color = Colors.orange;
        break;
      case 'cold':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Product list item widget
class ProductListItem extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductListItem({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListItemCard(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : Icon(
                Icons.image,
                color: Colors.grey[400],
              ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              if (onEdit != null) onEdit!();
              break;
            case 'delete':
              if (onDelete != null) onDelete!();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
