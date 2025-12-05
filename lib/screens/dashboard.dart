import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subtrack/widgets/subscription_stat_card.dart';
import 'package:subtrack/widgets/subscription_stat_card.dart';

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  final double totalSpending = 23.90;

  final Color activeColor = Color(0xFF0EB79E);
  final Color dueColor = Color(0xFFDC890D);
  final numOfActiveSubs = 7;
  final numOfDueSubs = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF272831),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 65),
                    Text(
                      "\$ $totalSpending",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Total spending",
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                      ),
                    ),
                    Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 13),
                              // 1. Active subs card
                              Expanded(
                                flex: 2,
                                child: SubscriptionStatCard.stat(
                                  count: numOfActiveSubs,
                                  label: 'ACTIVE \nSUBS',
                                  color: activeColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              //2. Due subs card
                              Expanded(
                                flex: 2,
                                child: SubscriptionStatCard.stat(
                                  count: numOfDueSubs,
                                  label: 'DUE \nSUBS',
                                  color: dueColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              // 3. Add button
                              Expanded(
                                flex: 1,
                                child: SubscriptionStatCard.addButton(),
                              ),
                              SizedBox(width: 13),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
