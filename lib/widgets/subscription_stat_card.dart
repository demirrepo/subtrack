import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subtrack/screens/add_subscription.dart';

// Enum to define the three possible styles/states of the card.
enum CardType { stat, addButton }

class SubscriptionStatCard extends StatelessWidget {
  final CardType type;
  final int? count; // Nullable for the addButton type
  final String? label; // Nullable for the addButton type
  final Color? color;

  // Named constructor for the standard 'stat' card (e.g., Active, Due)
  const SubscriptionStatCard.stat({
    Key? key,
    required this.count,
    required this.label,
    required this.color,
  }) : type = CardType.stat,
       super(key: key);

  // Named constructor for the '+' Add button card
  const SubscriptionStatCard.addButton({Key? key})
    : type = CardType.addButton,
      count = null,
      label = null,
      color = null,
      super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color.fromRGBO(30, 30, 30, 1.0);

    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child:
          type == CardType.stat
              ? _buildStatContent()
              : _buildAddButtonContent(context),
    );
  }

  // Content builder for the statistical cards (Active/Due)
  Widget _buildStatContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count!.toString(),
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 7.0),
        Text(
          label!,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Content builder for the '+' Add button card
  Widget _buildAddButtonContent(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSubscriptionPage()),
          );
        },
      ),
    );
  }
}
