import 'package:flutter/material.dart';

class FormActionButtons extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool isSaving;
  final bool isSaveEnabled;
  final String saveLabel;

  const FormActionButtons({
    super.key,
    this.onCancel,
    required this.onSave,
    this.isSaving = false,
    this.isSaveEnabled = true,
    this.saveLabel = 'Guardar',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFFB0B8C4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: AnimatedScale(
            scale: isSaveEnabled ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: isSaveEnabled
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7E57C2),
                          const Color(0xFF7E57C2).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7E57C2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: ElevatedButton(
                onPressed: isSaveEnabled && !isSaving ? onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaveEnabled
                      ? Colors.transparent
                      : const Color(0xFF7E57C2).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isSaveEnabled ? 0 : 0,
                  disabledBackgroundColor:
                      const Color(0xFF7E57C2).withOpacity(0.5),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        saveLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

