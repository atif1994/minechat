import 'package:flutter/material.dart';

/// Reusable Connection Status Widget - Reduces code duplication across channel widgets
class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String platformName;
  final String? connectionInfo;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final VoidCallback? onReconnect;
  final bool isLoading;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.platformName,
    this.connectionInfo,
    this.onConnect,
    this.onDisconnect,
    this.onReconnect,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green[300]! : Colors.red[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Icons.check : Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Status Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (connectionInfo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    connectionInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isConnected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onReconnect != null)
                  TextButton(
                    onPressed: onReconnect,
                    child: const Text('Reconnect'),
                  ),
                if (onDisconnect != null)
                  TextButton(
                    onPressed: onDisconnect,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Disconnect'),
                  ),
              ],
            )
          else if (onConnect != null)
            ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }
}
