import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minechat/core/controllers/base_controller.dart';

/// Base channel controller with common functionality
abstract class BaseChannelController extends BaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Common channel states
  var isConnected = false.obs;
  var isAIPaused = false.obs;
  var connectionStatus = 'Disconnected'.obs;
  
  // Common methods
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  
  /// Save connection status to Firestore
  Future<void> saveConnectionStatus(String platform, Map<String, dynamic> data) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return;
      
      await _firestore
          .collection('user_channels')
          .doc(userId)
          .set({
        platform: data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Saved $platform connection status');
    } catch (e) {
      print('❌ Error saving connection status: $e');
      setError('Failed to save connection status');
    }
  }
  
  /// Load connection status from Firestore
  Future<Map<String, dynamic>?> loadConnectionStatus(String platform) async {
    try {
      final userId = getCurrentUserId();
      if (userId.isEmpty) return null;
      
      final doc = await _firestore
          .collection('user_channels')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()?[platform] as Map<String, dynamic>?;
        return data;
      }
      
      return null;
    } catch (e) {
      print('❌ Error loading connection status: $e');
      return null;
    }
  }
  
  /// Validate required fields
  bool validateRequiredFields(Map<String, String> fields) {
    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        setError('${entry.key} is required');
        return false;
      }
    }
    return true;
  }
  
  /// Test connection - override in child classes
  Future<bool> testConnection() async {
    return false;
  }
  
  /// Connect to platform - override in child classes
  Future<void> connect() async {
    setLoading(true);
    try {
      await performConnection();
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      showSuccess('Successfully connected');
    } catch (e) {
      setError('Connection failed: ${e.toString()}');
      showError('Connection failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  /// Disconnect from platform - override in child classes
  Future<void> disconnect() async {
    setLoading(true);
    try {
      await performDisconnection();
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      showSuccess('Successfully disconnected');
    } catch (e) {
      setError('Disconnection failed: ${e.toString()}');
      showError('Disconnection failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
  
  /// Toggle AI pause state
  void toggleAIPause() {
    isAIPaused.value = !isAIPaused.value;
    final status = isAIPaused.value ? 'paused' : 'resumed';
    showInfo('AI assistant $status');
  }
  
  /// Perform actual connection - override in child classes
  Future<void> performConnection() async {}
  
  /// Perform actual disconnection - override in child classes
  Future<void> performDisconnection() async {}
}
