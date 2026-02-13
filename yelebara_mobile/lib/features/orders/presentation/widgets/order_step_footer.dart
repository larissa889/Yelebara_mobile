import 'package:flutter/material.dart';

class OrderStepFooter extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPressed;
  final String buttonText;
  final bool isEnabled;

  const OrderStepFooter({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onPressed,
    required this.buttonText,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSteps, (index) {
                final step = index + 1;
                final isActive = step == currentStep;
                final isCompleted = step < currentStep;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary
                        : isCompleted
                            ? colorScheme.primary.withOpacity(0.5)
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEnabled ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Match app style
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
