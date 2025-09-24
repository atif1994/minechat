import 'package:flutter/material.dart';
import '../forms/form_section_widget.dart';

/// Reusable FAQ Item Widget - Reduces FAQ item duplication across screens
class FAQItemWidget extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const FAQItemWidget({
    Key? key,
    required this.question,
    required this.answer,
    this.isExpanded = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (showActions) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: 'Edit FAQ',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            tooltip: 'Delete FAQ',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Answer Content
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable FAQ Form Widget - Reduces FAQ form duplication
class FAQFormWidget extends StatelessWidget {
  final TextEditingController questionController;
  final TextEditingController answerController;
  final String? questionError;
  final String? answerError;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isSaving;
  final String saveButtonText;

  const FAQFormWidget({
    Key? key,
    required this.questionController,
    required this.answerController,
    this.questionError,
    this.answerError,
    this.onSave,
    this.onCancel,
    this.isSaving = false,
    this.saveButtonText = 'Save FAQ',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Fields
          FormFieldWidget(
            label: 'Question',
            hintText: 'Enter the question',
            controller: questionController,
            errorText: questionError,
            isRequired: true,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FormFieldWidget(
            label: 'Answer',
            hintText: 'Enter the answer',
            controller: answerController,
            errorText: answerError,
            isRequired: true,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onCancel != null)
                TextButton(
                  onPressed: isSaving ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(saveButtonText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
