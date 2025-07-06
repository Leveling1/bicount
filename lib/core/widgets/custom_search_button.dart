import 'package:flutter/material.dart';

class CustomSearchButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomSearchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor, // Couleur gris clair
        shape: BoxShape.circle, // Forme circulaire
      ),
      child: Material(
        color: Colors.transparent, // Pour garder la couleur du Container
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(12.0), // Ajuste la taille du cercle
            child: Icon(Icons.search, color: Colors.black87, size: 24),
          ),
        ),
      ),
    );
  }
}
