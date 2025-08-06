import 'package:flutter/material.dart';
import 'app_button.dart';

class AppButtonExample extends StatelessWidget {
  const AppButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppButton Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Basic Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Primary Button
            AppButtonStyles.primary(
              text: 'Primary Button',
              onPressed: () => print('Primary button pressed'),
            ),
            const SizedBox(height: 12),
            
            // Secondary Button
            AppButtonStyles.secondary(
              text: 'Secondary Button',
              onPressed: () => print('Secondary button pressed'),
            ),
            const SizedBox(height: 12),
            
            // Gradient Button
            AppButtonStyles.gradient(
              text: 'Gradient Button',
              onPressed: () => print('Gradient button pressed'),
            ),
            const SizedBox(height: 12),
            
            // Outline Button
            AppButtonStyles.outline(
              text: 'Outline Button',
              onPressed: () => print('Outline button pressed'),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Buttons with Icons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Button with icon
            AppButton(
              text: 'Button with Icon',
              onPressed: () => print('Button with icon pressed'),
              icon: const Icon(Icons.favorite, size: 16),
              backgroundColor: Colors.pink,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Loading button
            AppButton(
              text: 'Loading Button',
              onPressed: null,
              isLoading: true,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Custom Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Custom styled button
            AppButton(
              text: 'Custom Styled',
              onPressed: () => print('Custom button pressed'),
              backgroundColor: Colors.purple,
              textColor: Colors.white,
              borderRadius: 30,
              height: 50,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Disabled button
            AppButton(
              text: 'Disabled Button',
              onPressed: () => print('This won\'t be called'),
              isEnabled: false,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Button with custom text style
            AppButton(
              text: 'Custom Text Style',
              onPressed: () => print('Custom text style button pressed'),
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Button Sizes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Small button
            AppButton(
              text: 'Small',
              onPressed: () => print('Small button pressed'),
              height: 32,
              width: 100,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Large button
            AppButton(
              text: 'Large Button',
              onPressed: () => print('Large button pressed'),
              height: 60,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            
            // Full width button
            AppButton(
              text: 'Full Width Button',
              onPressed: () => print('Full width button pressed'),
              backgroundColor: Colors.teal,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
} 