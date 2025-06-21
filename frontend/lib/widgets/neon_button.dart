import 'package:flutter/material.dart';
import '../app_theme.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed; // Делаем onPressed опциональным для неактивного состояния
  final IconData? icon;

  const NeonButton({
    required this.text,
    required this.onPressed,
    this.icon,
    super.key,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isHovering = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    // Анимируем наличие и интенсивность тени (свечения)
    final shadowOpacity = (isEnabled && (_isHovering || _isTapped)) ? 0.7 : 0.4;
    final blurRadius = (isEnabled && (_isHovering || _isTapped)) ? 15.0 : 8.0;
    final spreadRadius = (isEnabled && (_isHovering || _isTapped)) ? 3.0 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isTapped = true) : null,
        onTapUp: isEnabled ? (_) {
          setState(() => _isTapped = false);
          widget.onPressed!();
        } : null,
        onTapCancel: isEnabled ? () => setState(() => _isTapped = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            // Кнопка становится серой, если неактивна
            color: isEnabled ? AppTheme.primaryColor : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              // Тень есть только у активной кнопки
              if(isEnabled)
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(shadowOpacity),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: isEnabled ? Colors.black : Colors.grey.shade400, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: isEnabled ? Colors.black : Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}