import 'package:flutter/material.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onSave;

  const CustomNumpad({
    super.key,
    required this.onNumberPressed,
    required this.onClear,
    required this.onBackspace,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          Row(
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          Row(
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          Row(
            children: [
              _buildIconActionButton(Icons.backspace_outlined, onBackspace, color: Colors.grey.shade100),
              _buildNumberButton('0'),
              _buildIconActionButton(Icons.check, onSave, color: Colors.blue.shade600, iconColor: Colors.white, hasShadow: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: () => onNumberPressed(number),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: color ?? Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor ?? const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconActionButton(IconData icon, VoidCallback onTap, {Color? color, Color? iconColor, bool hasShadow = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: color ?? Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasShadow ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}
