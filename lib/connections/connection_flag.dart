import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionFlag extends StatelessWidget {
  ConnectionFlag({required this.status});
  final bool status;

  @override
  Widget build(BuildContext context) {
    Color color = status
        ? const Color.fromARGB(255, 0, 125, 4)
        : const Color.fromARGB(255, 220, 31, 18);
    String label = status ? 'CONNECTED' : 'NOT CONNECTED';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 5.0,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily,
            fontSize: 18,
          ),
        )
      ],
    );
  }
}
