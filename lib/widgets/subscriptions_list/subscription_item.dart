import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const SubscriptionItem({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'] ?? 'Unknown';
    final int cents = data['priceUsdCents'] ?? 0;
    final double price = cents / 100;

    final String status = (data['status'] ?? '').toString().toUpperCase();

    final Color statusColor =
        status == "ACTIVE"
            ? const Color(0xFF0EB79E)
            : status == "DUE"
            ? const Color(0xFFDC890D)
            : Colors.white70;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF474D75), width: 2.0),
      ),
      color: const Color(0xFF1C1D24),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // app icon (if stored in Firestore later, update this)
              Image.asset(
                'lib/assets/images/${name.toLowerCase()}.png',
                height: 50,
                width: 50,
                errorBuilder: (_, __, ___) => const Icon(Icons.apps, size: 40),
              ),

              const SizedBox(width: 10),

              // Subscription name
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Price
                  Text(
                    "\$ ${price.toStringAsFixed(2)}",
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),

                  // Status
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
