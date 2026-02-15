import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? underIconWidget;
  final Color activeColor; // Nowe pole na kolor podświetlenia
  final bool disabled;

  const SystemActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.underIconWidget,
    this.activeColor = Colors.orangeAccent,
    this.disabled = false, // Domyślnie pomarańczowy
  }) : super(key: key);

  @override
  State<SystemActionButton> createState() => _SystemActionButtonState();
}

class _SystemActionButtonState extends State<SystemActionButton> {
  bool _isPressed = false;

  void _handleTap() {
    setState(() => _isPressed = true);
    widget.onTap();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.disabled ? Colors.grey : Theme.of(context).primaryColor;
    final currentColor = _isPressed ? widget.activeColor : primary;

    return Center(
      child: GestureDetector(
        onTap: widget.disabled ? null : _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuint,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentColor.withOpacity(_isPressed ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: currentColor.withOpacity(_isPressed ? 0.8 : 0.3),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(_isPressed ? 0.4 : 0.0),
                        blurRadius: _isPressed ? 12 : 0,
                        spreadRadius: _isPressed ? 2 : 0,
                      )
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: currentColor,
                    size: 20,
                  ),
                ),
                if (widget.underIconWidget != null) Positioned(bottom: 4, child: widget.underIconWidget!),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuint,
              style: GoogleFonts.jetBrainsMono(
                color: currentColor.withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              child: Text(widget.label.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}
