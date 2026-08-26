import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: Text(
          'Orders',
          style:
          GoogleFonts.playfairDisplay(
            fontSize: 25,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 70,
              color: Color(0xFFB86F7B),
            ),

            const SizedBox(height: 18),

            Text(
              'Orders are coming soon',
              style:
              GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight:
                FontWeight.w600,
                color:
                const Color(
                  0xFF4B3439,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'This screen is ready for order management.',
              style:
              GoogleFonts.dmSans(
                color:
                const Color(
                  0xFF92797E,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}