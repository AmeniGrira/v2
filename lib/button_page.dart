import 'package:flutter/material.dart';

class ButtonPage extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double width; // Largeur fixe
  final double height; // Hauteur fixe

  const ButtonPage({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = Colors.blue,
    this.width = 200, // Taille par défaut de largeur
    this.height = 50, // Taille par défaut de hauteur
  }) : super(key: key);

  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width, // Largeur fixe
          height: widget.height, // Hauteur fixe
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color ?? Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.3),
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: widget.onPressed,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
